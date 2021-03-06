# Copyright @ 2019 Oslo University Hospital. All rights reserved.

EAPI=7

PYTHON_COMPAT=( python3_{8,9} )

inherit multibuild python-r1 cmake

# Short one-line description of this package.
DESCRIPTION="A set of common support code for medical imaging, surgical navigation, and related purposes"

# Homepage, not used by Portage directly but handy for developer reference
HOMEPAGE="https://www.commontk.org/"

COMMIT="ec816cbb77986f6ee28c41a495e82238dee0e2d3"

SRC_URI="https://github.com/commontk/CTK/archive/${COMMIT}.zip -> ${PN}-${PV}.zip"

LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64"

IUSE="python"


RDEPEND="
	python? ( ${PYTHON_DEPS}
			  dev-python/PythonQt_CTK
			  sci-libs/vtk[python] )
	!python? ( sci-libs/vtk )
	dev-qt/designer
	dev-qt/qtconcurrent
	dev-qt/qtcore
	dev-qt/qtgui
    dev-qt/qtmultimedia
	dev-qt/qtnetwork
	dev-qt/qtopengl
	dev-qt/qtsql
	dev-qt/qttest
	dev-qt/qtwidgets
	dev-qt/qtxmlpatterns
	dev-qt/qtxml
	sci-libs/itk
"
DEPEND="${RDEPEND}"

PATCHES=(
	${FILESDIR}/0001-COMP-Fix-Unknown-CMake-command-ctk_add_executable_ut.patch
	${FILESDIR}/0002-ENH-Include-missing-files.patch
	${FILESDIR}/0003-ENH-Change-installation-path-for-python-wrapped-file.patch
	${FILESDIR}/0004-ENH-Include-missing-ctkFunctionExtractOptimizedLibra.patch
)

src_unpack() {
	if [ "${A}"  != "" ]; then
		unpack ${A}
	fi

	mv ${WORKDIR}/CTK-${COMMIT} ${WORKDIR}/${PN}-${PV} || die
}

src_prepare() {

	cmake_src_prepare
}

src_configure(){

	configure() {

		local mycmakeargs=()

		mycmakeargs+=(
			-DCTK_QT_VERSION=5
			-DBUILD_TESTING=OFF
			-DCTK_BUILD_QTDESIGNER_PLUGINS=ON
			-DCTK_BUILD_SHARED_LIBS=ON
			-DCTK_ENABLE_DICOM=OFF
			-DCTK_ENABLE_PluginFramework=OFF
			-DCTK_ENABLE_Widgets=ON
			-DCTK_LIB_Core=ON
			-DCTK_LIB_ImageProcessing/ITK/Core=ON
			-DCTK_LIB_Visualization/VTK/Core=ON
			-DCTK_LIB_Visualization/VTK/Widgets=ON
			-DCTK_LIB_Visualization/VTK/Widgets_USE_TRANSFER_FUNCTION_CHARTS=ON
			-DCTK_SUPERBUILD=OFF
			-DCTK_INSTALL_LIB_DIR=/usr/lib64
			-DCTK_INSTALL_QTPLUGIN_DIR:STRING="/usr/lib64/qt5/plugins"
			# PythonQt wrapping
			-DCTK_LIB_Scripting/Python/Core:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Core_PYTHONQT_USE_VTK:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTCORE:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTGUI:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTUITOOLS:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTNETWORK:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Core_PYTHONQT_WRAP_QTWEBKIT:BOOL="$(usex python)"
			-DCTK_LIB_Scripting/Python/Widgets:BOOL="$(usex python)"
			-DCTK_ENABLE_Python_Wrapping:BOOL="$(usex python)"
		)

		if use python;then
			mycmakeargs+=(-DPYTHON_SITE_DIR=$(python_get_sitedir))
		fi

		cmake_src_configure
	}

	python_foreach_impl run_in_build_dir configure
}

src_compile()
{
	python_foreach_impl run_in_build_dir cmake_src_compile
}

src_install()
{
	python_foreach_impl run_in_build_dir cmake_src_install
}
