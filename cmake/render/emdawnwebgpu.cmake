function(mln_configure_emdawnwebgpu target)
  set(_emdawn_flags "--use-port=emdawnwebgpu")

  target_compile_options(
    ${target}
    PRIVATE
      "${_emdawn_flags}"
      "-fexceptions"
      "-sUSE_ZLIB=1"
      "-sUSE_LIBPNG=1"
      "-sUSE_LIBJPEG=1")
  target_link_options(
    ${target}
    PRIVATE
      "${_emdawn_flags}"
      "-sASYNCIFY"
      "-sNO_DISABLE_EXCEPTION_CATCHING"
      "-sUSE_ZLIB=1"
      "-sUSE_LIBPNG=1"
      "-sUSE_LIBJPEG=1"
      "-sFETCH=1"
      "-sENVIRONMENT=web,worker")
endfunction()

function(mln_prepare_emdawnwebgpu_vendor)
  if(NOT TARGET mbgl-vendor-dawn)
    add_library(mbgl-vendor-dawn INTERFACE)
    target_compile_options(
      mbgl-vendor-dawn
      INTERFACE
        "--use-port=emdawnwebgpu"
        "-fexceptions")
    target_link_options(
      mbgl-vendor-dawn
      INTERFACE
        "--use-port=emdawnwebgpu"
        "-sASYNCIFY"
        "-sNO_DISABLE_EXCEPTION_CATCHING"
        "-sUSE_ZLIB=1"
        "-sUSE_LIBPNG=1"
        "-sUSE_LIBJPEG=1"
        "-sFETCH=1"
        "-sENVIRONMENT=web,worker")
  endif()
endfunction()
