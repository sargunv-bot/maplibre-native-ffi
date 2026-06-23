function(mln_configure_webgpu_backend target)
  if(EMSCRIPTEN)
    set(MLN_FFI_VENDOR_WEBGPU_SOURCES)
  else()
    set(MLN_FFI_VENDOR_WEBGPU_SOURCES
        ${MLN_SOURCE_DIR}/src/mbgl/webgpu/headless_backend.cpp)
  endif()

  set(MLN_FFI_WEBGPU_SOURCES
      ${PROJECT_SOURCE_DIR}/src/render/webgpu/webgpu_surface_session.cpp
      ${PROJECT_SOURCE_DIR}/src/render/webgpu/webgpu_texture_session.cpp)

  if(MLN_FFI_VENDOR_WEBGPU_SOURCES)
    mln_target_vendor_sources(${target} ${MLN_FFI_VENDOR_WEBGPU_SOURCES})
  endif()
  mln_target_project_sources(${target} ${MLN_FFI_WEBGPU_SOURCES})

  target_compile_definitions(${target} PRIVATE MLN_RENDER_BACKEND_WEBGPU=1)

  if(EMSCRIPTEN)
    include(render/emdawnwebgpu)
    mln_configure_emdawnwebgpu(${target})
  elseif(MLN_FFI_WEBGPU_IMPL STREQUAL "dawn" OR MLN_FFI_WEBGPU_IMPL STREQUAL "emdawn")
    if(NOT TARGET mbgl-vendor-dawn)
      include(${MLN_SOURCE_DIR}/vendor/dawn.cmake)
    endif()
    if(TARGET mbgl-vendor-dawn)
      target_link_libraries(${target} PRIVATE mbgl-vendor-dawn)
    endif()
  elseif(MLN_FFI_WEBGPU_IMPL STREQUAL "wgpu")
    if(NOT TARGET mbgl-vendor-wgpu)
      include(${MLN_SOURCE_DIR}/vendor/wgpu.cmake)
    endif()
    if(TARGET mbgl-vendor-wgpu)
      target_link_libraries(${target} PRIVATE mbgl-vendor-wgpu)
    endif()
  endif()
endfunction()
