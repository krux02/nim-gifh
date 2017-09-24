
{.compile: "gif.c".}

type
  Writer = object
    f*: File
    oldImage*: pointer
    firstFrame*: bool

proc begin*(
  writer: ptr Writer, filename: cstring,
  width, height, delay: uint32,
  bitDepth: int32, dither: bool): bool {.importc: "GifBegin".}
## Creates a gif file.  The input GIFWriter is assumed to be
## uninitialized.  The delay value is the time between frames in
## hundredths of a second - note that not all viewers pay much
## attention to this value.

proc writeFrame*(
  writer: ptr Writer; image: pointer;
  width, height, delay: uint32;
  bitDepth: cint; dither: bool): bool {.importc: "GifWriteFrame".}
## Writes out a new frame to a GIF in progress.
## The GIFWriter should have been created by GIFBegin.
## AFAIK, it is legal to use different bit depths for different frames of an image -
## this may be handy to save bits in animations that don't change much.

proc gifEnd*(writer: ptr Writer): bool {. importc: "GifEnd".}
## Writes the EOF code, closes the file handle, and frees temp memory used by a GIF.
## Many if not most viewers will still display a GIF properly if the EOF code is missing,
## but it's still a good idea to write it out.
