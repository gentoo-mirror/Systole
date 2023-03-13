# Copyright @ 2019 Oslo University Hospital. All rights reserved.

EAPI=7

PYTHON_COMPAT=( python3_{9..10} )

inherit cmake python-single-r1 git-r3

# Short one-line description of this package.
DESCRIPTION="CropVolumeSequence module for 3D-Slicer"

EGIT_REPO_URI="https://github.com/Slicer/Slicer.git"
EGIT_BRANCH="main"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://www.slicer.org/"

LICENSE="BSD"

SLOT="0"

DEPEND="
	sci-medical/ctk[python]
	sci-medical/Slicer[python]
"

RDEPEND="
	${DEPEND}
	${PYTHON_DEPS}
"

BDEPEND="
"

PATCHES=(
	${FILESDIR}/0001-ENH-Make-CropVolumeSequence-a-separate-volume.patch
)

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

src_configure(){

	local mycmakeargs=()

	mycmakeargs+=(
		-DBUILD_TESTING:BOOL=OFF
		-DCMAKE_CXX_STANDARD:STRING="17"
		-DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=ON
		-DPYTHON_INCLUDE_DIR:STRING="$(python_get_sitedir)"
		-DSlicer_VTK_WRAP_HIERARCHY_DIR=${WORKDIR}
	)

	CMAKE_USE_DIR="${WORKDIR}/${P}/Modules/Scripted/${PN}"
	cmake_src_configure
}