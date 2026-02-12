#define HL_NAME(n) opus_##n
#include <hl.h>

#include <opusfile.h>

typedef struct _fmt_opus fmt_opus;
struct _fmt_opus {
	void (*finalize)(fmt_opus*);
	OggOpusFile* f;
	char* bytes;
	int pos;
	int size;
};

static void opus_finalize(fmt_opus* o) {
	op_free(o->f);
}

static int opus_memread(void* stream, unsigned char* ptr, int nbytes) {
	fmt_opus* o = (fmt_opus*)stream;
	int len = nbytes;

	if (o->pos + len > o->size)
		len = o->size - o->pos;
	if (len <= 0) return 0;

	memcpy(ptr, o->bytes + o->pos, len);
	o->pos += len;
	return len;
}

static int opus_memseek(void* stream, opus_int64 _offset, int whence) {
	fmt_opus* o = (fmt_opus*)stream;
	opus_int64 newpos;

	switch (whence) {
		case SEEK_SET:
			newpos = _offset;
			break;
		case SEEK_CUR:
			newpos = o->pos + _offset;
			break;
		case SEEK_END:
			newpos = o->size + _offset;
			break;
		default:
			return -1;
	}

	if (newpos < 0 || newpos > o->size) return -1;
	o->pos = (int)newpos;
	return 0;
}

static opus_int64 opus_memtell(void* stream) {
	fmt_opus* o = (fmt_opus*)stream;
	return o->pos;
}

static OpusFileCallbacks OPUS_CALLBACKS_MEMORY = {
	opus_memread,
	opus_memseek,
	opus_memtell,
	NULL
};

HL_PRIM fmt_opus* HL_NAME(opus_open)(char* bytes, int size) {
	int error = 0;
	fmt_opus* o = (fmt_opus*)hl_gc_alloc_finalizer(sizeof(fmt_opus));
	o->finalize = NULL;
	o->bytes = bytes;
	o->size = size;
	o->pos = 0;
	o->f = op_open_callbacks(o, &OPUS_CALLBACKS_MEMORY, NULL, 0, &error);

	if (error != 0 || o->f == NULL)
		return NULL;

	o->finalize = opus_finalize;
	return o;
}

HL_PRIM void HL_NAME(opus_info)(fmt_opus* o, int* freq, int* samples, int* channels) {
	const OpusHead* head = op_head(o->f, -1);
	*freq = 48000; // opus always decodes to 48kHz
	*channels = head->channel_count;
	*samples = (int)op_pcm_total(o->f, -1);
}

HL_PRIM int HL_NAME(opus_tell)(fmt_opus* o) {
	return (int)op_pcm_tell(o->f);
}

HL_PRIM bool HL_NAME(opus_seek)(fmt_opus* o, int sample) {
	return op_pcm_seek(o->f, sample) == 0;
}

HL_PRIM int HL_NAME(opus_read)(fmt_opus* o, char* output, int size, int format) {
	int total = 0;
	const OpusHead* head = op_head(o->f, -1);
	int ch = head->channel_count;
	int bps = (format == 2) ? 2 : 4; // bytes per sample per channel
	int samples_requested = size / (bps * ch);
	hl_blocking(true);

	while (samples_requested > 0) {
		int ret;

		if (format == 2)
			ret = op_read(o->f, (opus_int16*)output, samples_requested * ch, NULL);
		else
			ret = op_read_float(o->f, (float*)output, samples_requested * ch, NULL);

		if (ret < 0) {
			total = -1;
			break;
		}

		if (ret == 0) break;

		int bytes_read = ret * ch * bps;
		total += bytes_read;
		output += bytes_read;
		samples_requested -= ret;
	}

	hl_blocking(false);
	return total;
}

#define _OPUS _ABSTRACT(fmt_opus)

DEFINE_PRIM(_OPUS,		opus_open, _BYTES	_I32);
DEFINE_PRIM(_VOID,		opus_info, _OPUS	_REF(_I32) _REF(_I32) _REF(_I32));
DEFINE_PRIM(_I32,		opus_tell, _OPUS);
DEFINE_PRIM(_BOOL,		opus_seek, _OPUS	_I32);
DEFINE_PRIM(_I32,		opus_read, _OPUS	_BYTES _I32 _I32);
