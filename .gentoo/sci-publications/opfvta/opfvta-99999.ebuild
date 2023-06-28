# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )

inherit distutils-r1

DESCRIPTION="Whole-Brain Map and Assay Analysis of Mouse VTA Dopaminergic Activation"
HOMEPAGE="https://bitbucket.org/TheChymera/opfvta"

LICENSE="GPL-3"
SLOT="0"
IUSE="scanner-data"
KEYWORDS=""

DEPEND=""
RDEPEND="
	app-text/texlive[publishers,science,xetex]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	>=dev-python/seaborn-0.9.0[${PYTHON_USEDEP}]
	>=dev-python/statsmodels-0.9.0[${PYTHON_USEDEP}]
	>=dev-tex/pythontex-0.16[${PYTHON_USEDEP}]
	media-gfx/graphviz
	>=sci-biology/samri-0.4[${PYTHON_USEDEP}]
	scanner-data? ( sci-biology/opfvta_data )
	!scanner-data? ( sci-biology/opfvta_bidsdata )
"
