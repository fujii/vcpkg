include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gstreamer-1.12.4)
vcpkg_download_distfile(ARCHIVE
    URLS "https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.12.4.tar.xz"
    FILENAME "gstreamer-1.12.4.tar.xz"
    SHA512 849aa4ddf8ef465f2915e05d36fc0c31c2e31ae28be2fa38f8069a64a91b7347020fac5b881b7f3ee54c2198c3596138d49f27b09f258303834164a5d68b38a2
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_acquire_msys(MSYS_ROOT)
vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)
vcpkg_find_acquire_program(PERL)
vcpkg_find_acquire_program(PYTHON3)

get_filename_component(dir ${BISON} DIRECTORY)
set(ENV{PATH} "${dir};$ENV{PATH}")

get_filename_component(dir ${FLEX} DIRECTORY)
set(ENV{PATH} "${dir};$ENV{PATH}")

get_filename_component(dir ${PERL} DIRECTORY)
set(ENV{PATH} "${dir};$ENV{PATH}")

get_filename_component(dir ${PYTHON3} DIRECTORY)
set(ENV{PATH} "${dir};$ENV{PATH}")

set(ENV{PATH} "${CURRENT_BUILDTREES_DIR};$ENV{PATH}")

# for msgfmt and xgettext
set(ENV{PATH} "$ENV{PATH};${MSYS_ROOT}/usr/bin")

# fake pkg-config
configure_file(${CURRENT_PORT_DIR}/pkg-config.bat ${CURRENT_BUILDTREES_DIR}/pkg-config.bat @ONLY CRLF)
set(ENV{PKG_CONFIG} ${CURRENT_BUILDTREES_DIR}/pkg-config.bat)

# Add a shebang because Meson detects the interpreter command from it
file(READ ${CURRENT_INSTALLED_DIR}/tools/glib/glib-mkenums content)
file(WRITE ${CURRENT_BUILDTREES_DIR}/glib-mkenums "#! perl\n${content}")

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH})

# Build and install
vcpkg_install_meson()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gstreamer RENAME copyright)

# Move tools
set(tools_bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})
set(tools gst-inspect-1.0 gst-typefind-1.0 gst-launch-1.0 gst-stats-1.0)
file(MAKE_DIRECTORY ${tools_bin})
foreach(i IN LISTS tools)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${i}.exe ${tools_bin}/${i}.exe)
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/${i}.pdb ${tools_bin}/${i}.pdb)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${i}.exe)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${i}.pdb)
endforeach()

# Move plugins
set(plugins gstcoretracers gstcoreelements)
foreach(i IN LISTS plugins)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${i}.dll ${CURRENT_PACKAGES_DIR}/bin/${i}.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${i}.pdb ${CURRENT_PACKAGES_DIR}/bin/${i}.pdb)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0/${i}.lib ${CURRENT_PACKAGES_DIR}/lib/${i}.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${i}.dll ${CURRENT_PACKAGES_DIR}/debug/bin/${i}.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${i}.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/${i}.pdb)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0/${i}.lib ${CURRENT_PACKAGES_DIR}/debug/lib/${i}.lib)
endforeach()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/gstreamer-1.0)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/gstreamer-1.0)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

vcpkg_copy_tool_dependencies(${tools_bin})
vcpkg_copy_pdbs()
