# Editorial Decision Letter

**Journal:** Bioinformatics
**Title:** MKado: a toolkit for McDonald-Kreitman tests of natural selection

April 21, 2026
RE: G3-2026-406681


Dear Dr. Kern:

We are pleased to conditionally accept your manuscript titled "MKado: a toolkit for McDonald-Kreitman tests of natural selection" for publication in G3: Genes|Genomes|Genetics. We expect all remaining minor revisions can be completed within 30 days.

The reviewers were both very positive about the value of MKado. They highlight several areas where the manuscript should be modified for clarity, and we ask you to address those in your revision. They also provide detailed and constructive feedback about ways to extend and improve the software and documentation.

Follow this link to submit the revised manuscript: https://g3.msubmit.net/cgi-bin/main.plex?el=A6NQ7HwU2A6DLH7I7A9ftdJwe5Upqqpgguh7OEewgywZ

Prior to uploading your revised manuscript please format it according to G3 style and ensure you have all required elements. Author Guidelines are at https://academic.oup.com/g3journal/pages/author-guidelines#section-11. These guidelines have been updated with new requirements and your careful attention is required to avoid delays.

In your final submission, please include:
1. A clean version of your manuscript, formatted for G3
2. A highlighted or tracked version of your manuscript that links your response to reviewers via the current text
3. A separate document with a response to each of the editor's/reviewers' comments

Thank you for submitting your research to G3. As a fully open access journal of the Genetics Society of America (GSA), our mission is to publish peer-reviewed and peer-edited reproducible science with high-quality data. Thank you for your contribution.

Sincerely,

Matthew Rockman
Associate Editor
G3: Genes
Genomes
Genetics



Rob Kulathinal
Senior Editor
G3: Genes
Genomes
Genetics



---

## Reviewer #1

McDonald and Kreitman (MK) test is one of the most widely used methods to test for natural selection. Since its original publication, several studies have proven its potential for detecting positive selection. Nowadays, we have several extensions that mitigate the main issue of the MK test: the presence of slightly deleterious mutations. Here, the authors present a fast, user-friendly, and well-documented software to automatize MK tests. The software not only includes multiple MK tests extensions per gene or aggregated datasets, but also data processing, multiple testing correction, and visualization features. However, I have a few minor concerns that I hope the authors can address. Most of them should be straightforward to test or implement.

1. As the authors claim, most of the current software is fragmented. Some tools can deal with VCF or multi-FASTA data (degennotate, fastDFE, iMKT; https://doi.org/10.1093/molbev/msad270, https://doi.org/10.1093/molbev/msae070, https://doi.org/10.1093/nar/gkz372), some have already implemented several of the MK tests presented here (MKtest.jl; https://doi.org/10.1093/g3journal/jkae031), others can polarise alleles (fastDFE; https://doi.org/10.1093/molbev/msae070). MKado unifies it on a user-friendly python package. The documentation shows that MKado can deal with VCF files similarly to fastDFE, but I cannot see this mentioned in the paper. The authors should include it in the main text, since handling both VCF and multi-FASTA files is an important feature.

2. In addition to describing the Polarised MK Test, the authors should state in the main text that MKado uses outgroup sequences to polarize alleles. As far as I understand, this is done automatically and is well described in the software documentation. Nonetheless, I would recommend that the authors clarify the automatic allele polarization required to run tests such as the asymptotic or imputed MK tests (where polarization is mandatory or recommended), as distinct from the polarised MK test, which specifically tests for selection along a lineage. As I said, this is already well explained in the documentation, so it should be straightforward to include in the paper to avoid any misunderstanding.

3. When using the Tarone-Greenland Alpha, is the standard MK test applied? Would it not be beneficial to correct for slightly deleterious mutations by simply using the imputed or Fay, Wyckoff and Wu frequency threshold correction?

4. The authors should include an option to modify the SFS as described in Uricchio et al. (2019) (see supplementary material, https://doi.org/10.1038/s41559-019-0890-6):

   > We note that the original asymptotic-MK approach takes PN(x) and PS(x) as the number of polymorphic sites at frequency x rather than above x, but this approach scales poorly as sample size increases since most common allele frequencies x have very few polymorphic sites in large samples. We therefore define PN(x) and PS(x) as stated above since these quantities trivially have the same asymptote but are less affected by changing sample size.

   The asymptotic estimation would greatly benefit from this modification, producing more robust results. The authors can follow https://github.com/jmurga/MKtest.jl/blob/main/src/polymorphism.jl to implement it.

5. Do the runtime plots show only the batch processing of the 12,437 human genes, or also the execution of the imputed or standard MK test? If the tests are not included on runtime, I would recommend that the authors incorporate both processing and MK test estimation, since this should not substantially affect the benchmark. Moreover, I'm assuming the author are not providing runtime benchmark for asymptotic estimations. Because asymptotic estimation would probably fail at the gene level or provide unreliable results (as the authors properly note), I will recommend two approaches:

   i) Following Murga-Moreno et al. (2022) (https://doi.org/10.1093/g3journal/jkac206), the authors can aggregate at least 1,000 random genes to ensure reliable estimation on human data and run the benchmark over a reasonable number of replicates.

   ii) They can add the polyDFE bootstrapping strategy to resample the SFS over the 12,437 aggregated genes. This is a common strategy for obtaining reliable alpha confidence interval (CI) estimates (e.g., Castellano et al. 2019; https://doi.org/10.1534/genetics.119.302494). The authors currently estimate CI via Monte Carlo, but adding a bootstrap resampling strategy would benefit both runtime benchmarks and the reliability of alpha estimates for any MK test provided. See the bootstrapData function at https://github.com/paula-tataru/polyDFE/blob/master/postprocessing.R or https://fastdfe.readthedocs.io/en/latest/_modules/fastdfe/spectrum.html#Spectrum.resample.

   This way, non-expert users would not face runtimes longer than those shown in Figure S1. Since the software scaling is nearly perfect, testing approximately 1,000 aggregated datasets should be informative enough.

6. Since the authors already manually estimate the shortest mutational paths and weight synonymous and nonsynonymous sites following Nei and Gojobori (1986), can they include the total number of synonymous and nonsynonymous sites (Ls, Ln)? It should then be straightforward to also implement omega_a and omega_na, as decomposed in Coronado-Zamora et al. (2019) (https://academic.oup.com/gbe/article/11/5/1463/5480667):

   omega_a = alpha * omega
   omega_na = (1 - alpha) * omega

7. The authors followed an intelligent strategy using the OrthoMaM database to obtain human Dn, Ds, Pn, and Ps counts. I think projecting the polymorphic data onto the ortholog alignments could provide an useful feature when working with non-model species available within OrthoMaM database. I understand that including such a feature will be challenging, but a more detailed explanation of the polymorphism projection procedure would help users working with non-model organisms.

---

## Reviewer #2

This is a concise manuscript reporting a standalone package specifically designed for computing several flavours of the classical McDonald-Kreitman test. The length of the manuscript, level of details and information provided are appropriate. I agree with the authors that such as tool can be a benefit for the community by filling a gap in the set of available programs. I would say that MKado fulfils its tasks successfully. I had the chance to test the package and I found it satisfying so my review will be positive. Nevertheless I will seize this opportunity to provide feedback after looking at the code and testing the tool.

First of all, the text has a good structure. However, I would recommend that both the article and the documentation describe formally the basic statistics used. There are detailed formulas for variants of the MK tests, Dn and Ds are clearly defined, but Pn and Ps are not, actually (or not completely). I am surprised that the possibility of importing VCF data is not mentioned in the manuscript. I suppose that this was a recent addition to the package. This would be an attractive addition to the article. Figure 1 should be cited slightly differently as it shows both the volcano plot and the asymptotic MK test display.

The code is pure Python, so it is probably less efficient than what would have been achieved by a well-designed project including compiled code. The chosen strategy has advantages for clarity, maintenance and re-use. Furthermore, MKado makes uses of the Python package library when needed and seems to be designed and coded properly.

The code is extremely well structured and formatted throughout the project, with many comments and an extensive use of annotations, obviously with the help of automated tools. In this respect MKado is up to date with recent evolutions of the Python ecosystem, for both functionality (such as logging or typer) and development (e.g. uv and ruff). The main dependency is the Python version itself. MKado requires 3.12 which is two year old and two versions behind the current one, which may prevent installation on some outdated systems. MKado has dependencies on easily available generic packages (such as numpy) and only two specialized packages (cyvcf2 and pysam) which enable VCF support. No biological sequence managing library (such as Biopython) has been used and the management of sequence parsing (except VCF), data management, genetic code and coding regions has been implemented from scratch. As a pure Python package without complex dependencies, MKado should be portable with little difficulty.

The main `__init__.py` file is outdated as of this writing. First, the hardcoded version number is still 0.3.0 while the package has been ported to 0.4.0. Second, the package name in the file docstring is still "mikado", which is the original name of the project.

I installed the package with pip without any problem. The command was immediately available upon installation. Typing "mkado" alone (which I call the umbrella command) displays the manual, as I expected. I noticed that the umbrella command has options to manage shell completion. They were not clear to me at first sight and it is rather unexpected to find them as the option of the umbrella command, which is not expected to do anything. Maybe a "setup" command would clarify it but this is not essential. In any case I recommend adding a sentence to the help page to explain that these options allow to configure automatic shell completion. On my system, shell completion was painfully slow so the feature was doing more harm than good.

When called without argument, the different commands end up with an error, which is somewhat inconsistent with the behaviour of the umbrella command (which displays the help page). But it is a perfectly acceptable behaviour and up to the authors. Commands have logical and relevant options.

The commands write a progress bar and some feedback to the standard error stream, obviously to enable standard output redirection to capture the output. Unless I missed it, there is no way to specify and output file name. The choice that has been made is not perfectly complying with conventions regarding the use of the standard error stream but it is not unusual either.

The package is adequately documented by a fairly complete README available on the git and PyPI repositories, and, more in more details by a readthedocs page. [A] small remark would be that I don't think it is relevant to explain how to use ruff in the manual, as this is not needed to use MKado. By contrast, the shell completion options could be mentioned. There is somewhere the term "third outgroup" which I think is incorrect. Apart for this, the documentation is clear and complete, with very helpful commands.

Overall the command-line interface is well thought, immediately intuitive (except for shell completion option) and convenient. Only the meaning of the "aggregate" option was not clear to me. As samples are often grouped by population, it could be a possibility to allow specifying the ingroup and outgroup by range indexes, in top of the two possibilities already provided. This might be a feature request. Another suggestion is to support regular expressions to identify ingroup and outgroup samples in addition to an exact substring match.

The Python API is not particularly extensive but it is complete and it is well documented. It only took me a couple of minutes to write a script and run a simple analysis. The API allows further customization of analyses.

I tested the package over 100 coding sequence alignments simulated with a model without selection. At this small scale, running time is linear with the number of analyzed alignments. I noted an overhead of approximately 1.2s and found that most of it is caused by importing scipy.stats, at least on my system. The batch mode (as well as the Python API) effectively solves this issue by paying this overhead only once.

For large datasets it is still needed to use parallelization. However, Python isn't (currently) really good at parallelization. My feeling is that processing one alignment doesn't involve a lot of computation compared with the cost of spawning a worker (which entails creating a whole Python process) so the number of workers should be orders of magnitude below the number of genes (to avoid a waste of resources for little benefit). Figure S1 actually shows that the relationship is all but linear so I am not sure to agree with the sentence claiming that speedup is linear until 32 workers.

Plotting options and choosing the export format are nice features. I didn't explore all commands and options, but MKado offers a wide array of features that will be useful to the community. As a command-line tool with a properly defined command-line interface allowing robust and flexible configuration of input and output data, this tool will be convenient for bioinformaticians and can be easily integrated into analytical workflows (or even Python scripts thanks to the API). In addition, the authors have made efforts to provide an intuitive and user-friendly interface.
