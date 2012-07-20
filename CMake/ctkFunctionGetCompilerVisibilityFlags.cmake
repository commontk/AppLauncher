###########################################################################
#
#  Library:   CTK
#
#  Copyright (c) German Cancer Research Center,
#    Division of Medical and Biological Informatics
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0.txt
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
###########################################################################

#!
#! \brief Helper macro which appends gcc compatible visibility flags to the
#! variable given by RESULT_VAR.
#!
#! If supported, the flags -fvisibility=hidden and -fvisibility-inlines-hidden
#! will be added. This applies to gcc >= 4.5 and Clang.
#!
#! Usage:
#!   ctkFunctionGetCompilerVisibilityFlags(RESULT_VAR)
#!
#! Example:
#!
#! \code
#! set(myflags "-Werror")
#! ctkFunctionGetCompilerVisibilityFlags(myflags)
#! \endcode
#!
#! The variable \emph myflags will contain the string "-Werror -fvisibility -fvisibility-inlines-hidden"
#! if for example gcc 4.6 is used.
#!
#! \ingroup CMakeUtilities
function(ctkFunctionGetCompilerVisibilityFlags RESULT_VAR)
  
  # We only support hidden visibility for gcc for now. Clang 3.0 still has troubles with
  # correctly marking template declarations and explicit template instantiations as exported.
  # See http://comments.gmane.org/gmane.comp.compilers.clang.scm/50028
  # and http://llvm.org/bugs/show_bug.cgi?id=10113
  set(use_visibility_flags 0)

  if(CMAKE_COMPILER_IS_GNUCXX)
  
    set(use_visibility_flags 1)
    ctkFunctionGetGccVersion(${CMAKE_CXX_COMPILER} GCC_VERSION)
  
    # MinGW does not export all symbols automatically, so no need to set flags.
    #
    # With gcc < 4.5, RTTI symbols from classes declared in third-party libraries
    # which are not "gcc visibility aware" are marked with hidden visibility in
    # DSOs which include the class declaration and which are compiled with
    # hidden visibility. This leads to dynamic_cast and exception handling problems.
    # While this problem could be worked around by sandwiching the include
    # directives for the third-party headers between "#pragma visibility push/pop"
    # statements, it is generally safer to just use default visibility with
    # gcc < 4.5.
    
    if(${GCC_VERSION} VERSION_LESS "4.5" OR MINGW)
      set(use_visibility_flags 0)
    endif()
    
  endif()
  
  if(use_visibility_flags)
    set(visibility_flags "")
    ctkFunctionCheckCompilerFlags("-fvisibility=hidden" visibility_flags)
    ctkFunctionCheckCompilerFlags("-fvisibility-inlines-hidden" visibility_flags)
    set(${RESULT_VAR} "${${RESULT_VAR}} ${visibility_flags}" PARENT_SCOPE)
  endif()
  
endfunction()

