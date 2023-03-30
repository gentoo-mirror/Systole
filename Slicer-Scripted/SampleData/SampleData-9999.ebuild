# Copyright @ 2019-2023 Oslo University Hospital
# Distributed under the terms of the BSD 3 Clause License

EAPI=7

PYTHON_COMPAT=( python3_{9..10} )

inherit cmake python-single-r1 git-r3

# Short one-line description of this package.
DESCRIPTION="SampleData module for 3D-Slicer"

EGIT_REPO_URI="https://github.com/Slicer/Slicer.git"
EGIT_BRANCH="main"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://www.slicer.org/"

LICENSE="BSD"

SLOT="0"

DEPEND="
	sci-medical/Slicer[python]
	Slicer-Loadable/Volumes
"

RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
"

BDEPEND="
	sci-medical/ctk
"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}/0001-ENH-Make-SampleData-a-separate-module.patch"
)

src_configure(){

	local mycmakeargs=()

	mycmakeargs+=(
		-DBUILD_TESTING:BOOL=OFF
		-DCMAKE_CXX_STANDARD:STRING="17"
		-DPython3_INCLUDE_DIR:FILEPATH="$(python_get_includedir)"
		-DPython3_LIBRARY:FILEPATH="$(python_get_library_path)"
		-DPython3_EXECUTABLE:FILEPATH="${PYTHON}"
	)

	CMAKE_USE_DIR="${WORKDIR}/${P}/Modules/Scripted/${PN}"
	cmake_src_configure
}
