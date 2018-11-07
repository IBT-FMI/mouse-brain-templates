# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual : Generate a package-manager friendly mouse brain atlases collection"

SLOT="0"
KEYWORDS=""

RDEPEND="
	dev-python/numpy
	sci-biology/fsl
	sci-libs/nibabel
	sci-biology/ants
	sci-biology/nilearn
	sci-libs/scikits_image
	media-gfx/blender
	dev-python/pynrrd
	"

elog "Experimental package which only handles dependencies."
elog "No files will be installed."
elog "Scripts have to executed manually inside the repository."
