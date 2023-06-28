# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Whole-Brain Map and Assay Analysis of Mouse VTA Dopaminergic Activation"
HOMEPAGE="https://bitbucket.org/TheChymera/opfvta"

LICENSE="GPL-3"
SLOT="0"
IUSE="scanner-data"
KEYWORDS=""

DEPEND=""
RDEPEND="
	>=dev-python/repsep_utils-0.3.1
	>=dev-python/seaborn-0.9.0
	>=dev-python/statsmodels-0.9.0
	>=dev-tex/pythontex-0.16
	app-text/texlive[publishers,science,xetex]
	dev-python/matplotlib
	dev-python/numpy
	dev-python/pandas
	dev-tex/biblatex
	dev-tex/rubber
	media-gfx/graphviz
	sci-biology/ABI-connectivity-data
	sci-biology/samri
	scanner-data? ( sci-biology/opfvta_data )
	!scanner-data? ( sci-biology/opfvta_bidsdata )
"
