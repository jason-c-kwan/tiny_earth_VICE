#!/usr/bin/env python

import sys
import os
import pdb
import pandas as pd
# Finds the core genes that are found even in the smallest of reduced genome symbionts, from Prokka annotations
# See Nature Reviews Microbiology 2012, 10, 13-26.

def getInfo(info_string):
	info_list = info_string.split(';')
	entry_dict = dict()
	for entry in info_list:
		entry_list = entry.split('=')
		if entry_list[0] == 'gene':
			# Clean up gene name
			item = entry_list[1].split('_')[0]
			entry_dict[entry_list[0]] = item
		else:
			entry_dict[entry_list[0]] = entry_list[1]
	return entry_dict

def main():
	input_directory = sys.argv[1]

	gff_list = list()
	files_in_directory = os.listdir(input_directory)
	for file in files_in_directory:
		filepath = os.path.join(input_directory, file)
		if os.path.isfile(filepath) and filepath.split('.')[-1] == 'gff':
			gff_list.append(filepath)

	gene_list = [ 'dnaE', 'dnaQ', 'rpoA', 'rpoB', 'rpoC', 'rpoD', 'groL', 'groS', 'dnaK', 'mnmA', 'mnmE', 'mnmG', 'sufS', 'sufB', 'sufC', 'iscS', 'iscA', 'iscU', 'rluA', 'rluB', 'rluC', 'rluD', 'rluE', 'rluF', 'infA', 'infB', 'infC', 'fusA', 'tsf', 'prfA', 'prfB', 'frr', 'def', 'alaS', 'gltX', 'glyQ', 'ileS', 'metG', 'pheS', 'trpS', 'valS', 'rpsA', 'rpsB', 'rpsC', 'rpsD', 'rpsE', 'rpsG', 'rpsH', 'rpsI', 'rpsJ', 'rpsK', 'rpsL', 'rpsM', 'rpsN', 'rpsP', 'rpsQ', 'rpsR', 'rpsS', 'rplB', 'rplC', 'rplD', 'rplE', 'rplF', 'rplK', 'rplM', 'rplN', 'rplO', 'rplP', 'rplT', 'rplV', 'rpmA', 'rpmB', 'rpmG', 'rpmJ' ]

	tRNA_list = [ 'tRNA-Met', 'tRNA-Gly', 'tRNA-Cys', 'tRNA-Phe', 'tRNA-Lys', 'tRNA-Ala', 'tRNA-Glu', 'tRNA-Pro', 'tRNA-Gln', 'tRNA-Ile' ]

	gene_dict = dict() # Keyed by gff then by gene or tRNA, holds lists of locus tags

	for gene in gene_list:
		gene_dict[gene] = dict()

	for tRNA in tRNA_list:
		gene_dict[tRNA] = dict()

	gff_names = list()
	for gff_file in gff_list:
		gff_name = '.'.join(gff_file.split('/')[-1].split('.')[:-1])
		gff_names.append(gff_name)
		with open(gff_file) as gff:
			for line in gff:
				if len(line) > 2 and line[0:2] == '##':
					if len(line) > 7 and line[0:7] == '##FASTA':
						break
					else:
						continue
				else:
					line_list = line.rstrip().split('\t')
					record_type = line_list[2]
					info_string = line_list[8]
					info_dict = getInfo(info_string)
					if record_type == 'gene':
						if 'gene' in info_dict and info_dict['gene'] in gene_list:
							if gff_name in gene_dict[info_dict['gene']]:
								gene_dict[info_dict['gene']][gff_name].append(info_dict['locus_tag'])
							else:
								gene_dict[info_dict['gene']][gff_name] = [ info_dict['locus_tag'] ]
					elif record_type == 'tRNA':
						simple_product = info_dict['product'].split('(')[0]
						if simple_product in tRNA_list:
							if gff_name in gene_dict[simple_product]:
								gene_dict[simple_product][gff_name].append(info_dict['locus_tag'])
							else:
								gene_dict[simple_product][gff_name] = [ info_dict['locus_tag'] ]

	# Now we output the results
	core_df = pd.DataFrame.from_dict(gene_dict)
	core_counts = core_df.transpose().isnull().sum()
	core_count_df = core_counts.to_frame()
	core_count_df.columns = ['NA_count']
	core_count_df['Core_gene%'] = (84 - core_count_df['NA_count'])/84*100
	final_df = core_count_df.drop(['NA_count'], axis=1)
	final_df.to_csv(input_directory+'/Core_gene_completeness_estimates.tab', sep='\t', index=True)

main()