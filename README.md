# Alternative Splicing in Glioblastoma

This project expands on work by Wang et al. (2021), who analyzed how the alternative splicing (AS) landscape in glioblastoma (GBM) evolves between primary and recurrent tumors. Wang et al. analyzed 37 GBM samples collected from patient-matched longitudinal primary and recurrent tumors using an AS splicing tool called MAJIQ [1]. 

For my project, I explored whether I could recover recurrent-enriched AS events similar to those reported by Wang et al., but using a different patient cohort and a different AS analysis tool. Specifically, I used the INCB cohort, a public dataset collected in 2016 consisting of 26 primary and recurrent GBM samples. Instead of MAJIQ, I used SPLASH (see SPLASH github [here](https://github.com/refresh-bio/SPLASH)) [2]. 

Most bioinformatic pipelines, including MAJIQ, begin by aligning reads to a reference genome. The developers of SPLASH argue that early alignment can introduce uncertainty, reference bias, and loss of information, particularly in cancer data, where tumors often show large deviations from the reference genome. SPLASH is instead designed to detect biologically relevant signals directly from raw sequencing data using a k-mer–based approach.

Broadly speaking, SPLASH characterizes sequence variation using k-mer pairs called anchors and targets: anchors are k-mers that are conserved across samples, while targets are adjacent k-mers that differ between samples. For each anchor, SPLASH builds a contingency table in which rows represent targets, columns represent samples, and entries correspond to target counts per sample. A statistical test is then applied to compute a p-value quantifying whether the target frequencies associated with a given anchor differ significantly across samples [2].

To enable group-level interpretation, SPLASH provides a downstream supervised_test step, which fits a generalized linear model to identify anchors whose target distributions differ between predefined groups. In my analysis, I used this step to test for differences between primary and recurrent tumors.

### Procedure

I first built a small Nextflow pipeline to download the raw data, run SPLASH, and build a genome index (see main.nf). Raw RNA-seq data for the 26 samples were downloaded using the SRA Toolkit (modules/download_fastqs). I then ran the core SPLASH workflow on these raw fastqs (modules/splash_run). Because reads in this dataset are only 51 nucleotides long, I set the k-mer size to 21. I also used the --dump_sample_anchor_target_count_binary flag to support downstream supervised analysis. Next, I used NCBI Datasets command-line tools to download the human T2T genome FASTA and GTF files (modules/download_genome), which were then used to build a STAR genome index (modules/star_index). 

For downstream analysis, I used the scripts in the analysis_notebooks directory, which were adapted directly from the SPLASH GitHub notebooks, with only input and output file paths modified as needed. Specifically, I ran splash_build.Rmd to generate exon, splice site, and gene annotation files for the T2T genome, followed by splicing_analysis.Rmd to annotate anchor–target pairs with known genes and splicing events. Finally, I ran supervised_test.Rmd to identify sequences that differ between primary and recurrent tumor samples.  

### Additional Analysis

I noticed that the supervised_test script seemed highly sensitive to noise, particularly targets with very low counts that nonetheless strongly discriminated between groups. As a result, I created supervised_test_robust.Rmd, where I experimented with different methods of mitigating this issue, such as adjusting filtering thresholds and incorporating cross validation. Ultimately, I chose to simply filter out targets with particularly low counts as to not substantially alter the original logic of the script, though I do think this is something that could be explored further. 

### Results 

SPLASH identified 220 anchors with target distributions that differed significantly between primary and recurrent tumors, 202 of which mapped to genes in the T2T assembly. Wang et al. found 299 genes to be significantly alternatively spliced between primary and recurrent GBM tumors. Of these, 14 genes overlapped between the two analyses. 

Although this overlap is quite modest, several factors complicate direct comparison between the two studies. First, Wang et al. analyzed a larger and more recently collected dataset, providing greater statistical power and more up-to-date sequencing practices. Relatedly, SPLASH's default anchor length is 31, but I had to reduce it to 21 given the short read length of my dataset, which likely reduced the power of my methodology. Technical limitations aside, MAJIQ and SPLASH differ fundamentally in how alternative splicing is detected: MAJIQ models annotated splice junctions after read alignment, while SPLASH detects sequence variation directly from raw reads using a k-mer–based framework. These methodological differences influence both sensitivity and the types of splicing events that are detectable.

That said, two genes identified as significantly alternatively spliced between primary and recurrent tumors in both this analysis and that of Wang et al. were PTPRZ1 and RTN4. PTPRZ1 is a well-established marker of GBM stemness, and cancer stem cells are thought to play an important role in recurrence. In fact, a recent study by Chih et al. (2025) explores PTPRZ1 as a therapeutic target for T cell–based GBM therapies [3]. RTN4, an inhibitor of neurite growth and regeneration, is also significantly alternatively spliced between primary and recurrent tumor samples according to both analyses. Interestingly, a recent study by Feng et al. (2025) found RTN4 overexpression to be associated with unfavorable prognosis in gliomas [4]. The fact that PTPRZ1 and RTN4 were detected in both analyses as being alternatively spliced between primary and recurrent tumors is intriguing given their links to GBM stemness and adverse clinical outcomes.


### Citations
1. Wang, L., Shamardani, K., Babikir, H. et al. The evolution of alternative splicing in glioblastoma under therapy. Genome Biol 22, 48 (2021). https://doi.org/10.1186/s13059-021-02259-5 
2. Kaitlin Chaung, Tavor Z. Baharav, George Henderson, Ivan N. Zheludev, Peter L. Wang, Julia Salzman, SPLASH: A statistical, reference-free genomic algorithm unifies biological discovery, Cell, Volume 186, Issue 25, 2023, Pages 5440-5456.e26, ISSN 0092-8674, https://doi.org/10.1016/j.cell.2023.10.028. 
3. Chih, Y., Dietsch, A. C., Koopmann, P., Ma, X., Agardy, D. A., Zhao, B., De Roia, A., Kourtesakis, A., Kilian, M., Krämer, C., Suwala, A. K., Stenzinger, M., Boenig, H., Blum, A., Pienkowski, V. M., Aman, K., Becker, J. P., Feldmann, H., Bunse, T., . . .  Bunse, L. (2025). Vaccine-induced T cell receptor T cell therapy targeting a glioblastoma stemness antigen. Nature Communications, 16(1), 1262. https://doi.org/10.1038/s41467-025-56547-w
4. Feng, J., Zhao, L., Chen, H., Lin, J., Shang, M., Xu, B., Wang, X., Ma, D., Zhou, J., & Zhao, H. (2025). The Overexpression of RTN4 Significantly Associated With an Unfavourable Prognosis in Patients With Lower-Grade Gliomas. Journal of Cellular and Molecular Medicine, 29(4), e70418. https://doi.org/10.1111/jcmm.70418


