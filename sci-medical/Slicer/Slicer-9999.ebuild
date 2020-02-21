# Copyright @ 2019 Oslo University Hospital. All rights reserved.

EAPI=6

PYTHON_COMPAT=( python3_6 )

inherit cmake-utils python-r1 git-r3

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

RDEPEND="
	python? ( ${PYTHON_DEPS}
			  sci-medical/CTK[python] )
	!python? ( sci-medical/CTK )
	dev-qt/qtcore
	dev-qt/qtmultimedia
	dev-qt/qtopengl
	dev-qt/qtsql
	dev-qt/qtxmlpatterns
	dev-qt/qtwebengine
	dev-qt/qtwebchannel
	dev-qt/designer
	dev-libs/rapidjson
	dev-libs/jsoncpp
	sci-medical/CTKAppLauncherLib
	sci-medical/teem
	dev-python/PythonQt_CTK
	sci-libs/jqPlot
	cli? ( Slicer-CLI/SlicerExecutionModel )
"

DEPEND="${RDEPEND}"

IUSE="python cli"

PATCHES=(
	${FILESDIR}/0001-COMP-Remove-uneccessary-link-libraries-for-QTCore.patch
	${FILESDIR}/0002-COMP-Fix-link-libraries-in-QTGUI.patch
	${FILESDIR}/0003-COMP-Generate-and-Install-SlicerConfig-install-tree.patch
	${FILESDIR}/0004-COMP-Setting-CMAKE_MODULE_PATH-to-account-for-CTK-an.patch
	${FILESDIR}/0005-COMP-Add-installation-of-missing-files.patch
	${FILESDIR}/0006-COMP-Enable-install-of-development-files-in-Slicer-l.patch
	${FILESDIR}/0007-COMP-Adding-MRML_LIBRARIES-variable-to-install-confi.patch
	${FILESDIR}/0008-COMP-Change-Slicer_ROOT-by-Slicer_HOME-in-UseSlicer..patch
	${FILESDIR}/0009-COMP-Add-QTLOADABLEMODULES-dirs-in-intall-tree-confi.patch
	${FILESDIR}/0010-COMP-Adding-conditional-for-installation-of-QT-desig.patch
	${FILESDIR}/0011-COMP-Enable-installation-of-generated-.h-files-for-B.patch
	${FILESDIR}/0012-COMP-Enable-installation-of-header-files-for-qMRMLWi.patch
	${FILESDIR}/0013-COMP-Change-JsonCpp-by-jsoncpp.patch
	${FILESDIR}/0014-COMP-Adding-link-directories-for-ModuleParser.patch
	${FILESDIR}/0015-COMP-Change-installation-destination.patch
	${FILESDIR}/0016-COMP-Change-GLOB-filter-for-installing-vtkITK-dev-co.patch
	${FILESDIR}/0017-COMP-Add-Slicer_USE_PYTHONQT-as-condition-for-Module.patch
	${FILESDIR}/0018-COMP-Adding-MRMLCLI-include-directories-to-Slicer_Ba.patch
	${FILESDIR}/0019-COMP-Fix-install-path-for-CLI-modules.patch
	${FILESDIR}/0020-COMP-Fix-ITKFactoryRegistration-issues-on-install-tr.patch
	${FILESDIR}/0021-ENH-Enable-Python.patch
	${FILESDIR}/0022-ENH-Enable-external-definition-of-directories.patch
	${FILESDIR}/0023-COMP-Set-missing-variables-in-SlicerConfig-install-c.patch
	${FILESDIR}/0024-COMP-Add-needed-include-dirs-for-python-wrapping-of-.patch
	${FILESDIR}/0025-ENH-Make-available-paths-to-installed-qt-loadable-mo.patch
)

src_prepare() {

	cmake-utils_src_prepare
	cp ${FILESDIR}/FindPythonQt.cmake ${S}/CMake
}

src_configure(){

	configure() {
		local mycmakeargs=()

		mycmakeargs+=(
			-DSlicer_SUPERBUILD=OFF
			-DBUILD_TESTING=OFF
			-DSlicer_BUILD_EXTENSIONMANAGER_SUPPORT=OFF
			-DSlicer_BUILD_CLI_SUPPORT="$(usex cli)"
			-DSlicer_BUILD_CLI=OFF
			-DCMAKE_CXX_STANDARD=11
			-DSlicer_REQUIRED_QT_VERSION=5
			-DSlicer_BUILD_DICOM_SUPPORT=OFF
			-DSlicer_BUILD_ITKPython=OFF
			-DSlicer_BUILD_QTLOADABLEMODULES=OFF
			-DSlicer_BUILD_QTSCRIPTEDMODULES=OFF
			-DSlicer_BUILD_QT_DESIGNER_PLUGINS=ON
			-DSlicer_USE_CTKAPPLAUNCHER=OFF
			-DSlicer_USE_PYTHONQT="$(usex python)"
			-DSlicer_USE_QtTesting=OFF
			-DSlicer_USE_SimpleITK=OFF
			-DSlicer_VTK_RENDERING_BACKEND=OpenGL2
			-DSlicer_VTK_VERSION_MAJOR=8
			-DSlicer_INSTALL_DEVELOPMENT=ON
			-DCMAKE_INSTALL_RPATH=/usr/lib64/Slicer-4.11:/usr/lib64/ctk-0.1:/usr/lib64/Slicer-4.11/qt-loadable-modules:/usr/lib64/ITK-5.1.0:/usr/lib64/SlicerExecutionModel-1.0.0
			-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON
			-DTeem_DIR="/usr/lib64"
			-DSlicer_INSTALL_LIB_DIR="lib64/Slicer-4.11"
			-DjqPlot_DIR=/usr/share/jqPlot
			-DCTKAppLauncherLib_DIR=/usr/lib64/CTKAppLauncher-1.0.0
			-DSlicer_VTK_WRAP_HIERARCHY_DIR=${BUILD_DIR}
			-DSlicer_QTLOADABLEMODULES_LIB_DIR=lib64/Slicer-4.11/qt-loadable-modules
		)

		if use python; then
			mycmakeargs+=(-DPYTHON_SITE_DIR=$(python_get_sitedir))
		fi

		cmake-utils_src_configure
	}

	python_foreach_impl run_in_build_dir configure
}

pkg_postinst(){

	pythond_libraries=$(find /usr/lib64/Slicer-4.11 -name "*PythonD.so")
	for i in ${pythond_libraries}
	do
		ln -sf ${i} /usr/lib64/$(basename ${i}) || die
	done

	python_libraries=$(find /usr/lib64/Slicer-4.11 -name "*Python.so")
	for i in ${python_libraries}
	do
		ln -sf ${i} /usr/lib64/python3.6/site-packages/$(basename ${i}) || die
	done

}
