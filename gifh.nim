{.compile: "gif.c".}

type
  Writer* = object
    f*: File
    oldImage*: pointer
    firstFrame*: bool

proc begin*(
  writer: var Writer, filename: cstring,
  width, height, delay: int32,
  bitDepth: int32 = 8, dither: bool = false): bool {.importc: "GifBegin".}
## Creates a gif file.  The input GIFWriter is assumed to be
## uninitialized.  The delay value is the time between frames in
## hundredths of a second - note that not all viewers pay much
## attention to this value.

proc writeFrame*(
  writer: var Writer; image: pointer;
  width, height, delay: int32;
  bitDepth: int = 8; dither: bool = false): bool {.importc: "GifWriteFrame".}
## Writes out a new frame to a GIF in progress.
## The GIFWriter should have been created by GIFBegin.
## AFAIK, it is legal to use different bit depths for different frames of an image -
## this may be handy to save bits in animations that don't change much.

proc gifEnd*(writer: var Writer): bool {. importc: "GifEnd".}
## Writes the EOF code, closes the file handle, and frees temp memory used by a GIF.
## Many if not most viewers will still display a GIF properly if the EOF code is missing,
## but it's still a good idea to write it out.

when not defined(noSdlIntegration):
  import sdl2/sdl, opengl

  type
    GifAnimation* = object
      writer*: Writer
      w*,h*, delay*: int32
      bitDepth*: int32
      dither*: bool
      buffer*: seq[uint32]

  proc startGifAnimation*(this: var GifAnimation; window: Window, delay: int32; bitDepth: int32 = 8; dither: bool = false) =
    var w,h: cint
    getWindowSize(window, w.addr, h.addr)
    this.buffer = newSeq[uint32](w*h)
    this.w = w
    this.h = h
    this.delay = delay
    this.bitDepth = bitDepth
    this.dither = dither
    let filename = $getWindowTitle(window) & ".gif"
    doAssert this.writer.begin(filename, w, h, delay, bitDepth, dither)

  proc startGifAnimation*(window: Window, delay: int32; bitDepth: int32 = 8; dither: bool = false): GifAnimation =
    result.startGifAnimation(window,delay,bitDepth,dither)

  proc frameGifAnimationGl*(this: var GifAnimation): void =
    glReadPixels(0,0,this.w,this.h,GL_RGBA, GL_UNSIGNED_BYTE, this.buffer[0].addr)
    doAssert this.writer.writeFrame(this.buffer[0].addr, this.w, this.h, this.delay, this.bitDepth, this.dither)

  proc endGifAnimation*(this: var GifAnimation): void =
    doAssert this.writer.gifEnd()
    this.buffer = nil
