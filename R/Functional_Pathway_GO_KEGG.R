# This package will autamatically install org.Hs.eg.db, org.Rn.eg.db, org.Mm.eg.db. If you want to use different OrgDb annotation species, please install that annotation package and attach to your session.
DEGOAnalysis <- function(which.analysis, which.count.normalization, path.prefix, OrgDb.species) {
  cat(paste0("\n************** Gene Ontology Analysis **************\n"))
  if(!dir.exists(paste0(path.prefix, "RNAseq_results/", which.analysis, "/GO_analysis/"))){
    dir.create(paste0(path.prefix, "RNAseq_results/", which.analysis, "/GO_analysis/"))
  }
  # get return value
  DEUniv_results <- DEUnivGeneList(path.prefix = path.prefix, OrgDb.species = OrgDb.species)
  gene_list_SYMBOL = DEUniv_results$gene_list_SYMBOL_rt
  gene_list_SYMBOL_univ = DEUniv_results$gene_list_SYMBOL_univ_rt
  gene_list_ENTREZID = DEUniv_results$gene_list_ENTREZID_rt
  gene_list_ENTREZID_univ = DEUniv_results$gene_list_ENTREZID_univ_rt

  # DETranscript.limit <- 400
  GO.Ontology.list <- c("MF", "BP", "CC")
  for ( i in GO.Ontology.list) {
    cat("\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\u2605\n")
    cat(paste0("\u25CF Gene Ontology Analysis : '", i, "' group ... \n"))
    cat("\u25CF Checking differential expression gene number ... \n")
    # if (length(gene_list_SYMBOL) < DETranscript.limit && length(gene_list_ENTREZID) < DETranscript.limit) {
    cat(paste0("     \u25CF Differential expression gene number : ", length(gene_list_SYMBOL), "\n\n"))
    # Do GO Gene Set Enrichment Analysis
    dir_name <- paste0("GO_Gene_Set_Enrichment")
    if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name))){
      dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name))
    }
    if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i))){
      dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i))
    }
    cat("\u25CF GO Gene Set Enrichment Analysis ... \n")
    gse <- clusterProfiler::gseGO(geneList     = gene_list_ENTREZID_univ,
                                  OrgDb        = OrgDb.species,
                                  ont          = i,
                                  verbose      = FALSE)
    gse.data.frame <- data.frame(gse)
    if (length(row.names(gse.data.frame)) > 0) {
      # cat("     \u25CF Printing GO Gene Set Enrichment Analysis result \n")
      # print(head(gse.data.frame))
      if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images"))){
        dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images"))
      }
      # Result column must bigger than 0
      cat(paste0("     \u25CF (\u2714) GO Gene Set Enrichment test (", i,") enriched term found! \n"))
      cat(paste0("     \u25CF Writing 'GO_", i, "_Gene_Set_Enrichment.csv' \n"))
      write.csv(gse.data.frame, file = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/GO_", i, "_Gene_Set_Enrichment.csv"))
      cat(paste0("     \u25CF Checking 'GO_", i, "_Gene_Set_Enrichment.csv' result row number \n"))
      if (length(row.names(gse.data.frame)) < 5) {
        cat(paste0("          \u25CF 'GO_", i, "_Gene_Set_Enrichment.csv' result row number : ", length(row.names(gse.data.frame)), " (less than 5)\n"))
        for( GO.ID in gse.data.frame$ID) {
          cat(paste0("               \u25CF GO ID : ", GO.ID, "\n"))
          png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/", GO.ID, "_gseGO.png"))
          cat(paste0("               \u25CF Plotting '", GO.ID, "_gseGO.png'\n"))
          p <- clusterProfiler::gseaplot(gse, geneSetID = GO.ID)
          print(p)
          dev.off()
        }
      } else {
        cat(paste0("          \u25CF 'GO_", i, "_Gene_Set_Enrichment.csv' result row number : ", length(row.names(gse.data.frame)), " (more than 5)\n"))
        for(GO.ID in gse.data.frame$ID[seq_len(5)]) {
          cat(paste0("               \u25CF GO ID : ", GO.ID, "\n"))
          png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/", GO.ID, "_gseGO.png"))
          cat(paste0("               \u25CF Plotting '", GO.ID, "_gseGO.png'\n"))
          p <- clusterProfiler::gseaplot(gse, geneSetID = GO.ID)
          print(p)
          dev.off()
        }
      }
        cat("\n")
    } else {
      cat("     \u25CF (\u26A0) No enriched term is found.\n\n")
      file.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/GO_GSE_NO_TERM"))
    }
    # Do GO classification and GO over-representation test
    dir_name <- paste0("GO_DE_Classification_Erichment")
    if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name))){
      dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name))
    }
    if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i))){
      dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i))
    }
    if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images"))){
      dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images"))
    }
    cat("\u25CF GO Classification ... \n")
    # designed for gene classification on GO distribution at a specific level. "MF", "BP", "CC"
    ggo <- clusterProfiler::groupGO(gene     = names(gene_list_ENTREZID),
                                    OrgDb    = OrgDb.species,   # variable
                                    ont      = i,           # variable
                                    level    = 3,              # Not sure
                                    readable = TRUE)
    ggo.data.frame <- data.frame(ggo)
    # Condition 1 for GO classification ! Row number have to bigger than 1 !
    if (length(row.names(ggo.data.frame)) > 0) {
      # cat("     \u25CF Printing GO Classification result \n")
      # print(head(ggo.data.frame))
      cat(paste0("     \u25CF (\u2714) GO Classification (", i,") result found! \n"))
      cat(paste0("     \u25CF Writing 'GO_", i, "_Classification.csv' \n"))
      write.csv(ggo.data.frame, file = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i , "/GO_", i, "_Classification.csv"))
      cat(paste0("     \u25CF Plotting 'GO_", i, "_Classification_Bar_plot.png' \n\n"))
      png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/GO_", i, "_Classification_Bar_plot.png"))
      p1 <- barplot(ggo, drop=TRUE, showCategory=12)
      print(p1)
      dev.off()
    }  else {
      cat("     \u25CF (\u26A0) No term is found.\n\n")
      file.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/GO_CLASSIFICATION_NO_TERM"))
    }

    cat("\u25CF GO Enrichment Test ... \n")
    # GO over-representation test
    ego <- clusterProfiler::enrichGO(gene          = names(gene_list_ENTREZID),
                                     # universe      = geneList,
                                     OrgDb         = OrgDb.species,                   # variable
                                     ont           = i,
                                     pAdjustMethod = "BH",                            # variable : "holm", "hochberg", "hommel", "bonferroni", "BH", "BY", "fdr", "none"
                                     readable      = TRUE)
    ego.data.frame <- data.frame(ego)
    if (length(row.names(ego.data.frame)) >= 0) {
      # cat("     \u25CF Printing GO Enrichment result \n")
      # print(head(ggo.data.frame))
      cat(paste0("     \u25CF (\u2714) GO Enrichment test (", i,") enriched term found! \n"))
      cat(paste0("     \u25CF Writing 'GO_", i, "_Enrichment.csv' \n"))
      write.csv(ego.data.frame, file = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/GO_", i, "_Enrichment.csv"))
    } else {
      cat(paste0("     \u25CF (\u26A0) No enriched term is found.\n"))
      file.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/GO_ENRICHMENT_NO_TERM"))
    }
    # Condition 2 for GO Enrichment analysis ! Row numebr have to bigger or equal to 2 !
    if (length(row.names(ego.data.frame)) >= 2) {
      # bar plot
      png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/GO_", i, "_Enrichment_Bar_plot.png"))
      cat(paste0("     \u25CF Plotting 'GO_", i, "_Enrichment_Bar_plot.png' \n"))
      p2 <- barplot(ego, showCategory=12)
      print(p2)
      dev.off()

      # dot plot
      png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/GO_", i, "_Enrichment_Dot_plot.png"))
      cat(paste0("     \u25CF Plotting 'GO_", i, "_Enrichment_Dot_plot.png' \n"))
      p3 <- clusterProfiler::dotplot(ego)
      print(p3)
      dev.off()

      # have to check before run
      # no enriched term found
      png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/GO_", i, "_Enrichment_Map_plot.png"))
      cat(paste0("     \u25CF Plotting 'GO_", i, "_Enrichment_Map_plot.png' \n"))
      p4 <- clusterProfiler::emapplot(ego)
      print(p4)
      dev.off()

      ## categorySize can be scaled by 'pvalue' or 'geneNum'
      # the data frame should contain at least two columns
      png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/GO_", i, "_Enrichment_Complex_plot.png"))
      cat(paste0("     \u25CF Plotting 'GO_", i, "_Enrichment_Complex_plot.png' \n"))
      p5 <- clusterProfiler::cnetplot(ego, categorySize="pvalue", foldChange = gene_list_ENTREZID)
      print(p5)
      dev.off()

      # keys must be supplied in a character vector with no NAs
      png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/images/GO_", i, "_Enrichment_Induced_plot.png"))
      cat(paste0("     \u25CF Plotting 'GO_", i, "_Enrichment_Induced_plot.png' \n"))
      p6 <- clusterProfiler::goplot(ego)
      print(p6)
      dev.off()
      cat("\n")
    } else {
      cat(paste0("     \u25CF Row size of 'GO_", i,"_Enrichment.csv' is smaller than 2. Can't draw.\n"))
      file.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/GO_analysis/", dir_name, "/", i, "/GO_ENRICHMENT_LESS_THAN_2"))
    }
  }
}

DEKEGGAnalysis <- function(path.prefix, OrgDb.species, KEGG.organism) {
  cat(paste0("\n************** Kyoto Encyclopedia of Genes and Genomes Analysis **************\n"))
  if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/"))){
    cat("\u25CF Creating directory : 'RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/'\n")
    dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/"))
  }
  DEUniv_results <- DEUnivGeneList(path.prefix = path.prefix, OrgDb.species = OrgDb.species)
  gene_list_SYMBOL = DEUniv_results$gene_list_SYMBOL_rt
  gene_list_SYMBOL_univ = DEUniv_results$gene_list_SYMBOL_univ_rt
  gene_list_ENTREZID = DEUniv_results$gene_list_ENTREZID_rt
  gene_list_ENTREZID_univ = DEUniv_results$gene_list_ENTREZID_univ_rt
  cat("\u25CF Checking differential expression gene number ... \n")
  cat(paste0("     \u25CF Differential expression gene number : ", length(gene_list_SYMBOL), "\n\n"))
  # DETranscript.limit <- 400
  # Do KEGG Gene Set Enrichment Analysis
  dir_name <- paste0("KEGG_Gene_Set_Enrichment")
  if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name))){
    dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name))
  }
  cat("\u25CF KEGG Gene Set Enrichment Analysis ... \n")
  # DO KEGG Gene Set Enrichment Analysis
  kk.gse <- clusterProfiler::gseKEGG(geneList     = gene_list_ENTREZID_univ,
                                     organism     = KEGG.organism,
                                     verbose      = FALSE)
  kk.gse.frame <- data.frame(kk.gse)
  if (length(row.names(kk.gse.frame)) > 0) {
    # cat("     \u25CF Printing KEGG Gene Set Enrichment Analysis result \n")
    # print(head(kk.gse.frame))
    if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/images"))){
      dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/images"))
    }
    # Result column must bigger than 0
    cat(paste0("     \u25CF (\u2714) KEGG Gene Set Enrichment test enriched term found! \n"))
    cat(paste0("     \u25CF Writing 'KEGG_Gene_Set_Enrichment.csv' \n"))
    write.csv(kk.gse.frame, file = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/KEGG_Gene_Set_Enrichment.csv"))
    cat(paste0("     \u25CF Checking 'KEGG_Gene_Set_Enrichment.csv' result row number \n"))
    if (length(row.names(kk.gse.frame)) < 5) {
      cat(paste0("          \u25CF 'KEGG_Gene_Set_Enrichment.csv' result row number : ", length(row.names(kk.gse.frame)), " (less than 5)\n"))
      for( KEGG.ID in kk.gse.frame$ID) {
        print(KEGG.ID)
        png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/images/", KEGG.ID, "_gseGO.png"))
        p <- clusterProfiler::gseaplot(kk.gse, geneSetID = KEGG.ID)
        print(p)
        dev.off()
      }
    } else {
      cat(paste0("          \u25CF 'KEGG_Gene_Set_Enrichment.csv' result row number : ", length(row.names(kk.gse.frame)), " (more than 5)\n"))
      for(KEGG.ID in kk.gse.frame$ID[seq_len(5)]) {
        cat(paste0("               \u25CF KEGG ID : ", KEGG.ID, "\n"))
        png(filename = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/images/", KEGG.ID, "_gseGO.png"))
        cat(paste0("               \u25CF Plotting '", KEGG.ID, "_gseKEGG.png'\n"))
        p <- clusterProfiler::gseaplot(kk.gse, geneSetID = KEGG.ID)
        print(p)
        dev.off()
      }
    }
  } else {
    cat("     \u25CF (\u26A0) No enriched term is found.\n\n")
    file.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/KEGG_GSE_NO_TERM"))
  }
  dir_name <- paste0("KEGG_DE_Erichment")
  if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name))){
    dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name))
  }
  # Do KEGG over-representation test
  # organism : species supported at 'http://www.genome.jp/kegg/catalog/org_list.html'
  cat("\u25CF KEGG Enrichment Test ... \n")
  # KEGG Enrichment test
  kk <- clusterProfiler::enrichKEGG(gene         = names(gene_list_ENTREZID),
                                    organism     = KEGG.organism)                     # variable
  kk.data.frame <- data.frame(kk)
  # Row size have to bigger than 0!
  if (length(row.names(kk.data.frame)) > 0) {
    # cat("     \u25CF Printing KEGG Enrichment result \n")
    # print(head(kk.data.frame))
    cat(paste0("     \u25CF (\u2714) KEGG Enrichment test enriched term found! \n"))
    cat(paste0("     \u25CF Writing 'KEGG_Enrichment.csv' \n"))
    write.csv(kk.data.frame, file = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/KEGG_Enrichment.csv"))
    for ( i in kk.data.frame$ID) {
      if(!dir.exists(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/", i))){
        print(paste0("     \u25CF Creating directory 'RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/", i, "\n"))
        dir.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/", i))
      }
      current.path <- getwd()
      # get the url from KEGG result
      cat(paste0("     \u25CF Finding '", i, "' KEGG URL ... \n"))
      KEGGUrl <- GetKEGGUrl(kk, i)
      cat(paste0("     \u25CF Writting 'URL_", i, "_Pathway.txt' \n"))
      write(KEGGUrl, file = paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/", i, "/URL_", i, "_Pathway.txt"))
      # drawing pathway picture with 'pathway' package
      pathway.dir <- paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name, "/", i, "/pathview_result/")
      if(!dir.exists(pathway.dir)){
        dir.create(pathway.dir)
      }
      setwd(pathway.dir)
      cat(paste0("     \u25CF Plotting '", i, "' pathway by package \"pathview\" \n"))
      pathview::pathview(gene.data  = names(gene_list_ENTREZID),
                         pathway.id = i,
                         species    = KEGG.organism,
                         kegg.dir   = pathway.dir)
      on.exit(setwd(current.path))
    }
  } else {
    cat(paste0("     \u25CF (\u26A0) No enriched term is found.\n"))
    file.create(paste0(path.prefix, "RNAseq_results/Ballgown_FPKM_analysis/Differential_Expression/KEGG_analysis/", dir_name,"/KEGG_ENRICHMENT_NO_TERM"))
  }
}

DEUnivGeneList <- function(which.analysis, path.prefix, OrgDb.species) {
  DE.path.csv <- paste0(path.prefix, "RNAseq_results/", which.analysis, "/", strsplit(which.analysis, "_")[[1]][1], "_normalized_DE_result.csv")
  Univ.path.csv <- paste0(path.prefix, "RNAseq_results/", which.analysis, "/", strsplit(which.analysis, "_")[[1]][1], "_normalized_result.csv")
  DE.csv <- read.csv(DE.path.csv)
  Univ.csv <- read.csv(Univ.path.csv)
  # DE gene
  gene_list_SYMBOL <- DE.csv[DE.csv$gene_id != ".",]$fc
  gene_list_ENTREZID <- DE.csv[DE.csv$gene_id != ".",]$fc
  gene_name <- as.character(DE.csv[DE.csv$gene_id != ".",]$gene_id)

  # all ballgown gene
  gene_list_SYMBOL_univ <- Univ.csv[Univ.csv$gene_id != ".",]$fc
  gene_list_ENTREZID_univ <- Univ.csv[Univ.csv$gene_id != ".",]$fc
  gene_name_univ <- as.character(Univ.csv[Univ.csv$gene_id != ".",]$gene_id)
  # Rename gene_list_SYMBOL
  names(gene_list_SYMBOL) <-gene_name
  names(gene_list_SYMBOL_univ) <-gene_name_univ

  # Sort gene_list_SYMBOL
  gene_list_SYMBOL = sort(gene_list_SYMBOL, decreasing = TRUE)
  gene_list_SYMBOL_univ = sort(gene_list_SYMBOL_univ, decreasing = TRUE)

  # GO classification
  # GO classification : groupGO designed for gene classification based on GO distribution.
  # IDs conversion
  # OrgDb.species!!
  gene.df.DE <- clusterProfiler::bitr(gene_name, fromType = "SYMBOL",
                                      toType = c("ENTREZID", "ENSEMBL"),
                                      OrgDb = OrgDb.species)
  gene.df.Univ <- clusterProfiler::bitr(gene_name_univ, fromType = "SYMBOL",
                                        toType = c("ENTREZID", "ENSEMBL"),
                                        OrgDb = OrgDb.species)
  # Get ENTREZID for DE and Univ
  # DE
  ENTREZID_IDs.DE <- c()
  ENTREZID_IDs.DE <- lapply(gene_name, find_ENTREZID_ID_DE, gene.df.DE = gene.df.DE, ENTREZID_IDs.DE = ENTREZID_IDs.DE)
  names(gene_list_ENTREZID) <- ENTREZID_IDs.DE
  gene_list_ENTREZID = sort(gene_list_ENTREZID, decreasing = TRUE)
  # Univ
  ENTREZID_IDs_Univ <- c()
  ENTREZID_IDs_Univ <- lapply(gene_name_univ, find_ENTREZID_ID_Univ, gene.df.Univ = gene.df.Univ, ENTREZID_IDs_Univ = ENTREZID_IDs_Univ )
  names(gene_list_ENTREZID_univ) <- ENTREZID_IDs_Univ
  gene_list_ENTREZID_univ = sort(gene_list_ENTREZID_univ, decreasing = TRUE)
  return(list(gene_list_SYMBOL_rt = gene_list_SYMBOL,
              gene_list_SYMBOL_univ_rt = gene_list_SYMBOL_univ,
              gene_list_ENTREZID_rt = gene_list_ENTREZID,
              gene_list_ENTREZID_univ_rt = gene_list_ENTREZID_univ))
}

find_ENTREZID_ID_DE <- function(symbol.id, gene.df.DE, ENTREZID_IDs.DE) {
  ENTREZID_IDs.DE <- c(ENTREZID_IDs.DE, gene.df.DE[gene.df.DE$SYMBOL == symbol.id, ]["ENTREZID"][[1]][1])
  return(ENTREZID_IDs.DE)
}

find_ENTREZID_ID_Univ <- function(symbol.id, gene.df.Univ, ENTREZID_IDs_Univ) {
  ENTREZID_IDs_Univ <- c(ENTREZID_IDs_Univ, gene.df.Univ[gene.df.Univ$SYMBOL == symbol.id, ]["ENTREZID"][[1]][1])
  return(ENTREZID_IDs_Univ)
}

GetKEGGUrl <- function(x, pathID) {
  url <- paste0("http://www.kegg.jp/kegg-bin/show_pathway?", pathID, '/', x[pathID, "geneID"])
  return(url)
}


