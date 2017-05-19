find_package(Doxygen 1.8.4 QUIET)

if(NOT DOXYGEN_FOUND)
  return()
endif()
if(NOT DOXYGEN_DOT_FOUND)
  message(WARNING "Warning: Dot not found - Documentation will not be created")
  return()
endif()

#
# Documentation
#
set(doxyfile ${CMAKE_CURRENT_BINARY_DIR}/UserDoxyfile.txt)
set(doc_tarball
  ${DOCUMENTATION_ARCHIVES_OUTPUT_DIRECTORY}/${PROJECT_NAME}-cpp.tar.gz
  )

set(${PROJECT_NAME}_DEV_DOCUMENTATION "NO")
set(${PROJECT_NAME}_ADDITIONAL_EXCLUDE_PATTERN "*_p.h\  *Private.*")

configure_file(Doxyfile.txt.in ${doxyfile})

# Generate doxygen documentation
add_custom_target(cpp-doc
  COMMAND ${DOXYGEN_EXECUTABLE} ${doxyfile}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
add_dependencies(doc cpp-doc)

# Create documentation tarball
add_custom_target(cpp-doc-tarball-clean
  COMMAND ${CMAKE_COMMAND} -E remove ${doc_tarball}
  )

add_custom_target(cpp-doc-tarball
  DEPENDS cpp-doc cpp-doc-tarball-clean
  COMMAND ${CMAKE_COMMAND} -E tar cfz ${doc_tarball} html
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )
add_dependencies(doc-tarballs cpp-doc-tarball)

set_target_properties(cpp-doc cpp-doc-tarball
  PROPERTIES LABELS Documentation)

# Need to add EXCLUDE_FROM_DEFAULT_BUILD otherwise these targets would be built each time when build is started
# in the Visual Studio IDE (regardless of DOCUMENTATION_TARGET_IN_ALL setting).
set_target_properties(cpp-doc PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD 1)
set_target_properties(cpp-doc-tarball-clean PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD 1)
set_target_properties(cpp-doc-tarball PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD 1)
