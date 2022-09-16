#define JOIN0(a, b)                     a ## b
#define JOIN(a, b)                      JOIN0(a, b)
#define SnP_NHfield                     JOIN(SnP, _NHfield)
#define Cyclist_Per                     JOIN(prefix, _Per)

void Cyclist_Per(const uint8_t *input, const uint8_t *key, const uint8_t *output, size_t inputLen)
{
    SnP_NHfield(input, key, output, inputLen);
}


#undef Cyclist_Per
#undef SnP_NHfield

