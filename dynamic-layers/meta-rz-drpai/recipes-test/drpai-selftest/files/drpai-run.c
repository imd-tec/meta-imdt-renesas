// SPDX-License-Identifier: MIT
/*
 * Run a DRP-AI TVM model through the TVM C API and report the result.
 * usage: drpai-run <model_dir> <input.f32 (CHW float32)> <iterations> [freq]
 * Prints the top-5 classes of the first run, the timing, and how many later
 * runs gave a different output. Exits 3 if any run differed.
 */
#include <fcntl.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <time.h>
#include <unistd.h>

/* Just the parts of dlpack/TVM's C ABI that are used here. */
typedef struct { int32_t device_type, device_id; } DLDevice;
typedef struct { uint8_t code, bits; uint16_t lanes; } DLDataType;
typedef struct {
	void *data;
	DLDevice device;
	int32_t ndim;
	DLDataType dtype;
	int64_t *shape, *strides;
	uint64_t byte_offset;
} DLTensor;
typedef union { int64_t v_int64; double v_float64; void *v_handle; const char *v_str; } TVMValue;
typedef struct { const char *data; size_t size; } TVMByteArray;
enum { kInt = 0, kDLTensor = 7, kModule = 9, kStr = 11, kBytes = 12 };
#define kDLCPU 1
#define kDLDrpAi 36

int TVMModLoadFromFile(const char *, const char *, void **);
int TVMFuncGetGlobal(const char *, void **);
int TVMModGetFunction(void *, const char *, int, void **);
int TVMFuncCall(void *, TVMValue *, int *, int, TVMValue *, int *);
const char *TVMGetLastError(void);

#define CK(x) do { if ((x) != 0) { fprintf(stderr, "FAIL %s: %s\n", #x, TVMGetLastError()); exit(1); } } while (0)

struct drpai_area { uint64_t address, size; };
#define DRPAI_GET_DRPAI_AREA _IOR(0x2E, 11, struct drpai_area)

static void *slurp(const char *p, size_t *n)
{
	FILE *f = fopen(p, "rb");
	char *b;

	if (!f) { perror(p); exit(1); }
	fseek(f, 0, SEEK_END);
	*n = ftell(f);
	fseek(f, 0, SEEK_SET);
	b = malloc(*n + 1);
	if (fread(b, 1, *n, f) != *n) { perror(p); exit(1); }
	b[*n] = 0;
	fclose(f);
	return b;
}

static void *func(void *mod, const char *name)
{
	void *f = NULL;

	CK(TVMModGetFunction(mod, name, 0, &f));
	if (!f) { fprintf(stderr, "no function %s\n", name); exit(1); }
	return f;
}

static float h2f(uint16_t h)
{
	uint32_t s = h >> 15, e = (h >> 10) & 31, m = h & 1023;
	float v = e == 0 ? ldexpf(m, -24) : e == 31 ? INFINITY : ldexpf(m + 1024, e - 25);

	return s ? -v : v;
}

static double now(void)
{
	struct timespec t;

	clock_gettime(CLOCK_MONOTONIC, &t);
	return t.tv_sec + t.tv_nsec / 1e9;
}

int main(int argc, char **argv)
{
	const char *dir;
	int iters, freq, fd, rt, tc[4], mismatch = 0;
	struct drpai_area area;
	TVMValue a[4], r;
	TVMByteArray params;
	DLTensor *in, t;
	void *lib, *create, *ge, *run, *get_out;
	float *x, *first = NULL;
	int64_t on = 1;
	size_t n, want;
	double t0, tot, tmin = 1e9, tmax = 0;
	char p[512];
	char *json;

	if (argc < 4) {
		fprintf(stderr, "usage: %s model_dir input.f32 iterations [freq]\n", argv[0]);
		return 2;
	}
	dir = argv[1];
	iters = atoi(argv[3]);
	freq = argc > 4 ? atoi(argv[4]) : 2;

	fd = open("/dev/drpai0", O_RDWR);
	if (fd < 0 || ioctl(fd, DRPAI_GET_DRPAI_AREA, &area)) { perror("drpai area"); return 1; }
	close(fd);
	printf("drpai area 0x%llx size 0x%llx\n", (unsigned long long)area.address,
	       (unsigned long long)area.size);

	snprintf(p, sizeof(p), "%s/deploy.json", dir);
	json = slurp(p, &n);
	snprintf(p, sizeof(p), "%s/deploy.so", dir);
	CK(TVMModLoadFromFile(p, "so", &lib));
	CK(TVMFuncGetGlobal("tvm.graph_executor_debug.create", &create));
	a[0].v_str = json; tc[0] = kStr;
	a[1].v_handle = lib; tc[1] = kModule;
	a[2].v_int64 = kDLDrpAi; tc[2] = kInt;
	a[3].v_int64 = 0; tc[3] = kInt;
	CK(TVMFuncCall(create, a, tc, 4, &r, &rt));
	ge = r.v_handle;

	snprintf(p, sizeof(p), "%s/deploy.params", dir);
	params.data = slurp(p, &params.size);
	a[0].v_handle = &params; tc[0] = kBytes;
	CK(TVMFuncCall(func(ge, "load_params"), a, tc, 1, &r, &rt));
	a[0].v_int64 = area.address; tc[0] = kInt;
	CK(TVMFuncCall(func(ge, "set_start_address"), a, tc, 1, &r, &rt));

	a[0].v_int64 = 0; tc[0] = kInt;
	CK(TVMFuncCall(func(ge, "get_input"), a, tc, 1, &r, &rt));
	in = r.v_handle;
	want = in->dtype.bits / 8;
	printf("input shape");
	for (int i = 0; i < in->ndim; i++) {
		printf(" %lld", (long long)in->shape[i]);
		want *= in->shape[i];
	}
	printf(" dtype %d/%d\n", in->dtype.code, in->dtype.bits);
	x = slurp(argv[2], &n);
	if (n != want || in->dtype.bits != 32) {
		fprintf(stderr, "input is %zu bytes, model wants %zu float32 bytes\n", n, want);
		return 1;
	}

	t = *in;
	t.data = x;
	t.device.device_type = kDLCPU;
	t.device.device_id = 0;
	t.strides = NULL;
	t.byte_offset = 0;
	a[0].v_int64 = 0; tc[0] = kInt;
	a[1].v_handle = &t; tc[1] = kDLTensor;
	CK(TVMFuncCall(func(ge, "set_input"), a, tc, 2, &r, &rt));

	run = func(ge, "run");
	get_out = func(ge, "get_output");
	t0 = now();
	for (int it = 0; it < iters; it++) {
		DLTensor *o;
		float *v;
		double s = now(), d;

		a[0].v_int64 = freq; tc[0] = kInt;
		CK(TVMFuncCall(run, a, tc, 1, &r, &rt));
		d = now() - s;
		tmin = d < tmin ? d : tmin;
		tmax = d > tmax ? d : tmax;

		a[0].v_int64 = 0; tc[0] = kInt;
		CK(TVMFuncCall(get_out, a, tc, 1, &r, &rt));
		o = r.v_handle;
		on = 1;
		for (int i = 0; i < o->ndim; i++)
			on *= o->shape[i];
		v = malloc(on * sizeof(float));
		for (int64_t i = 0; i < on; i++)
			v[i] = o->dtype.bits == 16 ? h2f(((uint16_t *)o->data)[i]) : ((float *)o->data)[i];
		if (!first) {
			first = v;
			printf("output elems %lld dtype %d/%d\n", (long long)on, o->dtype.code, o->dtype.bits);
		} else {
			if (memcmp(first, v, on * sizeof(float)))
				mismatch++;
			free(v);
		}
	}
	tot = now() - t0;
	printf("runs %d avg %.2f ms min %.2f max %.2f, output mismatches vs run 1: %d\n",
	       iters, tot / iters * 1e3, tmin * 1e3, tmax * 1e3, mismatch);

	/* Top-5 of the softmax of the first run. */
	{
		float mx = -INFINITY, sum = 0;

		for (int64_t i = 0; i < on; i++)
			mx = first[i] > mx ? first[i] : mx;
		for (int64_t i = 0; i < on; i++)
			sum += expf(first[i] - mx);
		for (int k = 0; k < 5 && k < on; k++) {
			int64_t b = 0;

			for (int64_t i = 1; i < on; i++)
				if (first[i] > first[b])
					b = i;
			printf("top%d class %lld prob %.4f\n", k + 1, (long long)b, expf(first[b] - mx) / sum);
			first[b] = -INFINITY;
		}
	}
	return mismatch ? 3 : 0;
}
