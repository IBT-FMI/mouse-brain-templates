# Mouse Brain Atlases Generator Workflows

Scripts to build the mouse brain atlases collection used by [SAMRI](https://github.com/IBT-FMI/SAMRI) and more generally by the ETH and Univeristy of Zurich Animal Imaging Center.

**N.B.** Most of the volumetric data fetched and bundled in this archive are created by us, all credit goes to the original authors, see our [fair use and citation notice](FAIRUSE-AND-CITATION).

# Mouse Brain Atlases Package Releases

Current recommended release in bold typeface, basic resolution and HD packages with archive checksums linked in parentheses:

* **[mouse-brain-atlases-0.3](http://chymera.eu/distfiles/mouse-brain-atlases-0.3.tar.xz)**([checksum](http://chymera.eu/distfiles/mouse-brain-atlases-0.3.sha512)), **[mouse-brain-atlasesHD-0.3](http://chymera.eu/distfiles/mouse-brain-atlasesHD-0.3.tar.xz)** ([checksum](http://chymera.eu/distfiles/mouse-brain-atlases-0.3.sha512))
* [mouse-brain-atlases-0.2](http://chymera.eu/distfiles/mouse-brain-atlases-0.2.20180719.tar.xz) ([checksum](http://chymera.eu/distfiles/mouse-brain-atlases-0.2.20180719.sha512)), [mouse-brain-atlasesHD-0.2](http://chymera.eu/distfiles/mouse-brain-atlasesHD-0.2.20180719.tar.xz) ([checksum](http://chymera.eu/distfiles/mouse-brain-atlasesHD-0.2.20180719.sha512))

# Constituent Atlases

The `mouse-brain-atlases` archives generated by these scripts include the constituent atlases at the original resolution and at 40 and 200 micron downsamplings, with appropriate smoothing.
Additionally, standard space modifications are applied, e.g. to conform to the NIfTI-conform SAMRI standard space (RAS orientation with Paxinos Bregma origin).

* [AMBMC](http://imaging.org.au/AMBMC/Model):
 	* `ambmc` - Reoriented in RAS space, with affine coordinates relative to Paxinos Bregma origin.
	* `lambmc` -  With deleted orientation (legacy).
* [DSURQE](http://repo.mouseimaging.ca/repo/DSURQE_40micron_nifti):
 	* `dsurqe` - Affine coordinates relative to Paxinos Bregma origin.
	* `ldsurqe` - With deleted orientation (analogous to `lambmc` and created for comparison with it).
* [ABI](http://download.alleninstitute.org/informatics-archive/current-release/mouse_ccf/average_template/average_template_10.nrrd):
 	* `abi` - Oriented in RAS space.


