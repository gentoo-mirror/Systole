# Copyright @ 2019 Oslo University Hospital. All rights reserved.

EAPI=7

inherit cmake multilib git-r3

# Short one-line description of this package.
DESCRIPTION="3D Slicer is an open source software platform for medical image informatics,
image processing, and three-dimensional visualization. This package is a
live-build which will pull the master branch of the official 3D Slicer repository."

EGIT_REPO_URI="https://github.com/Slicer/Slicer.git"
EGIT_BRANCH="master"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://www.slicer.org/"

LICENSE="BSD"

SLOT="0"

KEYWORDS="~amd64"

DEPEND="
	sci-medical/Slicer
"

RDEPEND="${DEPEND}"

PATCHES=(
	${FILESDIR}/0001-COMP-Make-DataProbe-a-separate-module.patch
)

src_prepare() {

	cmake_src_prepare
}

src_configure(){

	local mycmakeargs=()

	mycmakeargs+=(
		-DBUILD_TESTING=OFF
		-DCMAKE_CXX_STANDARD=11
		-DCMAKE_INSTALL_RPATH=/usr/lib64/Slicer-4.11:/usr/lib64/ctk-0.1:/usr/lib64/Slicer-4.11/qt-loadable-modules:/usr/lib64/ITK-5.1.0
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
		-DSlicer_VTK_WRAP_HIERARCHY_DIR=${WORKDIR}
		-DSlicer_QTLOADABLEMODULES_LIB_DIR=lib64/Slicer-4.11/qt-loadable-modules
		-DSlicer_QTSCRIPTEDMODULES_LIB_DIR=/lib64/Slicer-4.11/qt-scripted-modules
		-DSlicer_INSTALL_QTSCRIPTEDMODULES_LIB_DIR=lib64/Slicer-4.11/qt-scripted-modules
		-DPYTHON_INCLUDE_DIR="/usr/include/python3.6m"
	)

	CMAKE_USE_DIR="${WORKDIR}/${P}/Modules/Scripted/${PN}"
	cmake_src_configure
}
