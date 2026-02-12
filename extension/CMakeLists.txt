add_library(extension SHARED "extension.cpp")

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET extension PROPERTY CXX_STANDARD 20)
endif()

set_target_properties(extension PROPERTIES
	OUTPUT_NAME "opus"
	SUFFIX ".hdll")

target_include_directories(extension PRIVATE "$ENV{HASHLINK}/include")
target_link_libraries(extension PRIVATE "$ENV{HASHLINK}/libhl.lib")

set(OPUSFILE_INCLUDE_DIR "lib/opusfile")
set(OPUS_SRC_DIR "lib/opus")
set(OPUS_INCLUDE_DIR "${OPUS_SRC_DIR}/include")

target_sources(extension PRIVATE
    "${OPUSFILE_INCLUDE_DIR}/opusfile.c"
    "${OPUSFILE_INCLUDE_DIR}/info.c"
    "${OPUSFILE_INCLUDE_DIR}/stream.c"
    "${OPUSFILE_INCLUDE_DIR}/internal.c")

if (WIN32)
   target_sources(extension PRIVATE
    ${OPUS_SRC_DIR}/src/opus.c
    ${OPUS_SRC_DIR}/src/opus_decoder.c
    ${OPUS_SRC_DIR}/src/opus_encoder.c
    ${OPUS_SRC_DIR}/src/extensions.c
    ${OPUS_SRC_DIR}/src/opus_multistream.c
    ${OPUS_SRC_DIR}/src/opus_multistream_encoder.c
    ${OPUS_SRC_DIR}/src/opus_multistream_decoder.c
    ${OPUS_SRC_DIR}/src/repacketizer.c
    ${OPUS_SRC_DIR}/src/opus_projection_encoder.c
    ${OPUS_SRC_DIR}/src/opus_projection_decoder.c
    ${OPUS_SRC_DIR}/src/mapping_matrix.c
    ${OPUS_SRC_DIR}/src/analysis.c
    ${OPUS_SRC_DIR}/src/mlp.c
    ${OPUS_SRC_DIR}/src/mlp_data.c
    ${OPUS_SRC_DIR}/celt/bands.c
    ${OPUS_SRC_DIR}/celt/celt.c
    ${OPUS_SRC_DIR}/celt/celt_encoder.c
    ${OPUS_SRC_DIR}/celt/celt_decoder.c
    ${OPUS_SRC_DIR}/celt/cwrs.c
    ${OPUS_SRC_DIR}/celt/entcode.c
    ${OPUS_SRC_DIR}/celt/entdec.c
    ${OPUS_SRC_DIR}/celt/entenc.c
    ${OPUS_SRC_DIR}/celt/kiss_fft.c
    ${OPUS_SRC_DIR}/celt/mini_kfft.c
    ${OPUS_SRC_DIR}/celt/laplace.c
    ${OPUS_SRC_DIR}/celt/mathops.c
    ${OPUS_SRC_DIR}/celt/mdct.c
    ${OPUS_SRC_DIR}/celt/modes.c
    ${OPUS_SRC_DIR}/celt/pitch.c
    ${OPUS_SRC_DIR}/celt/celt_lpc.c
    ${OPUS_SRC_DIR}/celt/quant_bands.c
    ${OPUS_SRC_DIR}/celt/rate.c
    ${OPUS_SRC_DIR}/celt/vq.c
    ${OPUS_SRC_DIR}/silk/CNG.c
    ${OPUS_SRC_DIR}/silk/code_signs.c
    ${OPUS_SRC_DIR}/silk/init_decoder.c
    ${OPUS_SRC_DIR}/silk/decode_core.c
    ${OPUS_SRC_DIR}/silk/decode_frame.c
    ${OPUS_SRC_DIR}/silk/decode_parameters.c
    ${OPUS_SRC_DIR}/silk/decode_indices.c
    ${OPUS_SRC_DIR}/silk/decode_pulses.c
    ${OPUS_SRC_DIR}/silk/decoder_set_fs.c
    ${OPUS_SRC_DIR}/silk/dec_API.c
    ${OPUS_SRC_DIR}/silk/enc_API.c
    ${OPUS_SRC_DIR}/silk/encode_indices.c
    ${OPUS_SRC_DIR}/silk/encode_pulses.c
    ${OPUS_SRC_DIR}/silk/gain_quant.c
    ${OPUS_SRC_DIR}/silk/interpolate.c
    ${OPUS_SRC_DIR}/silk/LP_variable_cutoff.c
    ${OPUS_SRC_DIR}/silk/NLSF_decode.c
    ${OPUS_SRC_DIR}/silk/NSQ.c
    ${OPUS_SRC_DIR}/silk/NSQ_del_dec.c
    ${OPUS_SRC_DIR}/silk/PLC.c
    ${OPUS_SRC_DIR}/silk/shell_coder.c
    ${OPUS_SRC_DIR}/silk/tables_gain.c
    ${OPUS_SRC_DIR}/silk/tables_LTP.c
    ${OPUS_SRC_DIR}/silk/tables_NLSF_CB_NB_MB.c
    ${OPUS_SRC_DIR}/silk/tables_NLSF_CB_WB.c
    ${OPUS_SRC_DIR}/silk/tables_other.c
    ${OPUS_SRC_DIR}/silk/tables_pitch_lag.c
    ${OPUS_SRC_DIR}/silk/tables_pulses_per_block.c
    ${OPUS_SRC_DIR}/silk/VAD.c
    ${OPUS_SRC_DIR}/silk/control_audio_bandwidth.c
    ${OPUS_SRC_DIR}/silk/quant_LTP_gains.c
    ${OPUS_SRC_DIR}/silk/VQ_WMat_EC.c
    ${OPUS_SRC_DIR}/silk/HP_variable_cutoff.c
    ${OPUS_SRC_DIR}/silk/NLSF_encode.c
    ${OPUS_SRC_DIR}/silk/NLSF_VQ.c
    ${OPUS_SRC_DIR}/silk/NLSF_unpack.c
    ${OPUS_SRC_DIR}/silk/NLSF_del_dec_quant.c
    ${OPUS_SRC_DIR}/silk/process_NLSFs.c
    ${OPUS_SRC_DIR}/silk/stereo_LR_to_MS.c
    ${OPUS_SRC_DIR}/silk/stereo_MS_to_LR.c
    ${OPUS_SRC_DIR}/silk/check_control_input.c
    ${OPUS_SRC_DIR}/silk/control_SNR.c
    ${OPUS_SRC_DIR}/silk/init_encoder.c
    ${OPUS_SRC_DIR}/silk/control_codec.c
    ${OPUS_SRC_DIR}/silk/A2NLSF.c
    ${OPUS_SRC_DIR}/silk/ana_filt_bank_1.c
    ${OPUS_SRC_DIR}/silk/biquad_alt.c
    ${OPUS_SRC_DIR}/silk/bwexpander_32.c
    ${OPUS_SRC_DIR}/silk/bwexpander.c
    ${OPUS_SRC_DIR}/silk/debug.c
    ${OPUS_SRC_DIR}/silk/decode_pitch.c
    ${OPUS_SRC_DIR}/silk/inner_prod_aligned.c
    ${OPUS_SRC_DIR}/silk/lin2log.c
    ${OPUS_SRC_DIR}/silk/log2lin.c
    ${OPUS_SRC_DIR}/silk/LPC_analysis_filter.c
    ${OPUS_SRC_DIR}/silk/LPC_inv_pred_gain.c
    ${OPUS_SRC_DIR}/silk/table_LSF_cos.c
    ${OPUS_SRC_DIR}/silk/NLSF2A.c
    ${OPUS_SRC_DIR}/silk/NLSF_stabilize.c
    ${OPUS_SRC_DIR}/silk/NLSF_VQ_weights_laroia.c
    ${OPUS_SRC_DIR}/silk/pitch_est_tables.c
    ${OPUS_SRC_DIR}/silk/resampler.c
    ${OPUS_SRC_DIR}/silk/resampler_down2_3.c
    ${OPUS_SRC_DIR}/silk/resampler_down2.c
    ${OPUS_SRC_DIR}/silk/resampler_private_AR2.c
    ${OPUS_SRC_DIR}/silk/resampler_private_down_FIR.c
    ${OPUS_SRC_DIR}/silk/resampler_private_IIR_FIR.c
    ${OPUS_SRC_DIR}/silk/resampler_private_up2_HQ.c
    ${OPUS_SRC_DIR}/silk/resampler_rom.c
    ${OPUS_SRC_DIR}/silk/sigm_Q15.c
    ${OPUS_SRC_DIR}/silk/sort.c
    ${OPUS_SRC_DIR}/silk/sum_sqr_shift.c
    ${OPUS_SRC_DIR}/silk/stereo_decode_pred.c
    ${OPUS_SRC_DIR}/silk/stereo_encode_pred.c
    ${OPUS_SRC_DIR}/silk/stereo_find_predictor.c
    ${OPUS_SRC_DIR}/silk/stereo_quant_pred.c
    ${OPUS_SRC_DIR}/silk/LPC_fit.c
    ${OPUS_SRC_DIR}/silk/float/apply_sine_window_FLP.c
    ${OPUS_SRC_DIR}/silk/float/corrMatrix_FLP.c
    ${OPUS_SRC_DIR}/silk/float/encode_frame_FLP.c
    ${OPUS_SRC_DIR}/silk/float/find_LPC_FLP.c
    ${OPUS_SRC_DIR}/silk/float/find_LTP_FLP.c
    ${OPUS_SRC_DIR}/silk/float/find_pitch_lags_FLP.c
    ${OPUS_SRC_DIR}/silk/float/find_pred_coefs_FLP.c
    ${OPUS_SRC_DIR}/silk/float/LPC_analysis_filter_FLP.c
    ${OPUS_SRC_DIR}/silk/float/LTP_analysis_filter_FLP.c
    ${OPUS_SRC_DIR}/silk/float/LTP_scale_ctrl_FLP.c
    ${OPUS_SRC_DIR}/silk/float/noise_shape_analysis_FLP.c
    ${OPUS_SRC_DIR}/silk/float/process_gains_FLP.c
    ${OPUS_SRC_DIR}/silk/float/regularize_correlations_FLP.c
    ${OPUS_SRC_DIR}/silk/float/residual_energy_FLP.c
    ${OPUS_SRC_DIR}/silk/float/warped_autocorrelation_FLP.c
    ${OPUS_SRC_DIR}/silk/float/wrappers_FLP.c
    ${OPUS_SRC_DIR}/silk/float/autocorrelation_FLP.c
    ${OPUS_SRC_DIR}/silk/float/burg_modified_FLP.c
    ${OPUS_SRC_DIR}/silk/float/bwexpander_FLP.c
    ${OPUS_SRC_DIR}/silk/float/energy_FLP.c
    ${OPUS_SRC_DIR}/silk/float/inner_product_FLP.c
    ${OPUS_SRC_DIR}/silk/float/k2a_FLP.c
    ${OPUS_SRC_DIR}/silk/float/LPC_inv_pred_gain_FLP.c
    ${OPUS_SRC_DIR}/silk/float/pitch_analysis_core_FLP.c
    ${OPUS_SRC_DIR}/silk/float/scale_copy_vector_FLP.c
    ${OPUS_SRC_DIR}/silk/float/scale_vector_FLP.c
    ${OPUS_SRC_DIR}/silk/float/schur_FLP.c
    ${OPUS_SRC_DIR}/silk/float/sort_FLP.c)

    target_compile_definitions(extension PRIVATE
        OPUS_BUILD
        USE_ALLOCA
        HAVE_LRINTF
        HAVE_CONFIG_H)
    target_include_directories(extension PRIVATE
        ${OPUSFILE_INCLUDE_DIR}
        ${OPUS_INCLUDE_DIR}
        ${OPUS_SRC_DIR})

    file(GLOB OPUS_SRC_FILES "${OPUS_SRC_DIR}/src/*.c")
    file(GLOB OPUS_CELT_FILES "${OPUS_SRC_DIR}/celt/*.c")
    file(GLOB OPUS_SILK_FILES "${OPUS_SRC_DIR}/silk/*.c")
    file(GLOB OPUS_SILK_FLOAT_FILES "${OPUS_SRC_DIR}/silk/float/*.c")
    # set_source_files_properties(${OPUS_SRC_FILES} PROPERTIES
    #     INCLUDE_DIRECTORIES "${OPUS_SRC_DIR}/celt;${OPUS_SRC_DIR}/silk;${OPUS_SRC_DIR}/silk/float;${OPUS_INCLUDE_DIR};${OPUS_SRC_DIR}")
    # set_source_files_properties(${OPUS_CELT_FILES} PROPERTIES
    #     INCLUDE_DIRECTORIES "${OPUS_SRC_DIR}/celt;${OPUS_INCLUDE_DIR};${OPUS_SRC_DIR}")
    # set_source_files_properties(${OPUS_SILK_FILES} PROPERTIES
    #     INCLUDE_DIRECTORIES "${OPUS_SRC_DIR}/silk;${OPUS_SRC_DIR}/silk/float;${OPUS_SRC_DIR}/celt;${OPUS_INCLUDE_DIR};${OPUS_SRC_DIR}")
    # set_source_files_properties(${OPUS_SILK_FLOAT_FILES} PROPERTIES
    #     INCLUDE_DIRECTORIES "${OPUS_SRC_DIR}/silk/float;${OPUS_SRC_DIR}/silk;${OPUS_SRC_DIR}/celt;${OPUS_INCLUDE_DIR};${OPUS_SRC_DIR}")
    # set(OPUS_LIBRARIES)
    target_include_directories(extension PRIVATE "${OPUS_SRC_DIR}/celt" "${OPUS_SRC_DIR}/silk" "${OPUS_SRC_DIR}/silk/float" "${OPUS_INCLUDE_DIR}" "${OPUS_SRC_DIR}")
    target_include_directories(extension PRIVATE "${OPUS_SRC_DIR}/celt" "${OPUS_INCLUDE_DIR}" "${OPUS_SRC_DIR}")
    target_include_directories(extension PRIVATE "${OPUS_SRC_DIR}/silk" "${OPUS_SRC_DIR}/silk/float" "${OPUS_SRC_DIR}/celt" "${OPUS_INCLUDE_DIR}" "${OPUS_SRC_DIR}")
    target_include_directories(extension PRIVATE "${OPUS_SRC_DIR}/silk/float" "${OPUS_SRC_DIR}/silk" "${OPUS_SRC_DIR}/celt" "${OPUS_INCLUDE_DIR}" "${OPUS_SRC_DIR}")
else()
    target_include_directories(extension PRIVATE ${OPUSFILE_INCLUDE_DIR} ${OPUS_INCLUDE_DIR})

    include(ExternalProject)

    if (NOT DEFINED CMAKE_COMMON_DEP_ARGS)
        set(CMAKE_COMMON_DEP_ARGS
            -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON
            -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
            -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
            -DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM})
    endif()

    ExternalProject_Add(libopus
        URL https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz
        URL_HASH SHA256=6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1
        CMAKE_ARGS
            ${CMAKE_COMMON_DEP_ARGS}
            -DBUILD_SHARED_LIBS=OFF
            -DCMAKE_INSTALL_LIBDIR=lib
            -DOPUS_BUILD_TESTING=OFF
            -DOPUS_BUILD_PROGRAMS=OFF
            -DOPUS_INSTALL_PKG_CONFIG_MODULE=OFF
            -DOPUS_INSTALL_CMAKE_CONFIG_MODULE=OFF
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/libopus.a)
    ExternalProject_Get_Property(libopus INSTALL_DIR)
    set(OPUS_INSTALL_DIR ${INSTALL_DIR})

    add_library(opus_lib STATIC IMPORTED)
    set_target_properties(opus_lib PROPERTIES IMPORTED_LOCATION ${OPUS_INSTALL_DIR}/lib/libopus.a)
    add_dependencies(opus_lib libopus)

    if (NOT DOWNLOAD_DEPENDENCIES)
        pkg_check_modules(OPUSFILE_OGG REQUIRED ogg)
        set(OPUS_OGG_LIBRARIES ${OPUSFILE_OGG_LINK_LIBRARIES})
    endif()

    set(OPUS_LIBRARIES opus_lib)
    if (NOT DOWNLOAD_DEPENDENCIES)
        list(APPEND OPUS_LIBRARIES ${OPUS_OGG_LIBRARIES})
    endif()
    list(APPEND OPUS_LIBRARIES m)

    add_dependencies(extension libopus)
endif()

if (WIN32)
    set(VORBIS_INCLUDE_DIR "lib/vorbis")

    target_sources(extension PRIVATE
        "${VORBIS_INCLUDE_DIR}/bitrate.c"
        "${VORBIS_INCLUDE_DIR}/bitwise.c"
        "${VORBIS_INCLUDE_DIR}/block.c"
        "${VORBIS_INCLUDE_DIR}/codebook.c"
        "${VORBIS_INCLUDE_DIR}/envelope.c"
        "${VORBIS_INCLUDE_DIR}/floor0.c"
        "${VORBIS_INCLUDE_DIR}/floor1.c"
        "${VORBIS_INCLUDE_DIR}/framing.c"
        "${VORBIS_INCLUDE_DIR}/info.c"
        "${VORBIS_INCLUDE_DIR}/lookup.c"
        "${VORBIS_INCLUDE_DIR}/lpc.c"
        "${VORBIS_INCLUDE_DIR}/lsp.c"
        "${VORBIS_INCLUDE_DIR}/mapping0.c"
        "${VORBIS_INCLUDE_DIR}/mdct.c"
        "${VORBIS_INCLUDE_DIR}/psy.c"
        "${VORBIS_INCLUDE_DIR}/registry.c"
        "${VORBIS_INCLUDE_DIR}/res0.c"
        "${VORBIS_INCLUDE_DIR}/sharedbook.c"
        "${VORBIS_INCLUDE_DIR}/smallft.c"
        "${VORBIS_INCLUDE_DIR}/synthesis.c"
        "${VORBIS_INCLUDE_DIR}/vorbisfile.c"
        "${VORBIS_INCLUDE_DIR}/window.c")
    target_include_directories(extension PRIVATE ${VORBIS_INCLUDE_DIR})
endif()