#ifndef UNI_UTF8_H
#define UNI_UTF8_H

static inline int is_utf8_continuation_byte(char c)
{
    return (c & 0xC0) == 0x80;
}

#endif
