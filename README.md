# bbbq_1

The first sub-question of the Bianchi, Bilderbeek and Bogaart Question.

 * :lock: [Full article](https://github.com/richelbilderbeek/bbbq_article)

## File structure

I've separated this regarding the two `make` calls.

### 1. `make peregrine`

Run this on Peregrine.

Creates all:

 * `[target]_[haplotype_id]_ic50s.csv`
 * `[target]_topology.csv`

#### `haplotypes.csv`

`haplotype`  |`haplotype_id`
-------------|--------------
HLA-A*01:01  |h1
HLA-A*02:01  |h2
...          |...
HLA-DRB3*0101|h14
HLA-DRB3*0202|h15

```
Rscript create_haplotypes.R
```

#### `[target].fasta`

The proteome

```
> Somethingine
AAACCCVVVVAAACCCVVVVAAACCCVVVVAAACCCVVVV
> Somethingase
AAACCCVVVVAAACCCVVVVAAACCC
```

```
Rscript get_proteome.R covid
Rscript get_proteome.R human
```

#### `[target]_proteins.csv`

`protein_id`|`protein`     |`sequence`
------------|--------------|----------------------------------------
p1          |Somethingine  |AAACCCVVVVAAACCCVVVVAAACCCVVVVAAACCCVVVV
p2          |Somethingase  |AAACCCVVVVAAACCCVVVVAAACCC

```
Rscript create_proteins.R covid
Rscript create_proteins.R human
```

#### `[target]_peptides.csv`

`protein_id`|`start_pos` |`peptide`
------------|------------|------------
p1          |1           |AAACCCVVVV

```
Rscript create_peptides.R covid
Rscript create_peptides.R human
```

#### `[target]_topology.csv`

`protein_id`|`topology`
------------|----------------------------------------
p1          |0000000000001111111111111000000000000000
p2          |00000000000000000000000000

```
Rscript create_topology.R covid
Rscript create_topology.R myco
```

#### `[target]_[haplotype_id]_ic50s.csv`

`protein_id`|`start_pos` |`ic50`
------------|------------|----------
p1          |1           |123.456
p1          |2           |234.567

:warning: Use `sbatch` to generate these files

```
sbatch Rscript predict_ic50s.R covid h1
sbatch Rscript predict_ic50s.R covid h2
...
sbatch Rscript predict_ic50s.R covid h14
sbatch Rscript predict_ic50s.R covid h15
...
```

### 2. `make results`

### `[target]_coincidence.csv

Per protein, counts the spots and TMH spots

`protein_id`|`n_spots`|`n_spots_tmh`
------------|---------|-------------
p1          |3        |1
p2          |4        |2

```
Rscript count_coincidence_tmh.R covid
Rscript count_coincidence_tmh.R human
```

### `[target]_binders.csv`

For all proteins, counts the number of binders and the number of TMHs that are TMH

`protein_id`|`haplotype_id`|`n_binders`|`n_binders_tmh`
------------|--------------|-----------|---------------
p1          |h1            |11         |5
p2          |h1            |12         |6
...         |...           |...        |
p1          |h2            |13         |7
p2          |h2            |14         |8

```
Rscript count_binders_tmh.R covid
Rscript count_binders_tmh.R human
```

### `table_tmh_binders_raw.csv`

`target`|`haplotype_id`|`n_binders`|`n_binders_tmh`
--------|--------------|-----------|---------------
covid   |h1            |29         |12
covid   |h2            |28         |13
...     |...           |...        |...
human   |h1            |39         |22
human   |h2            |38         |23

```
Rscript create_table_tmh_binders_raw.R
```

### `table_tmh_binders_mhc[mhc_class].csv`

Pretty-printed version

`haplotype`|`covid`      |`human`
-----------|-------------|-------------
HLA-A*01:01| 38.46 (5/13)| 25.00 (5/20)
HLA-B*39:01| 100.00 (2/2)|58.33 (14/24)
HLA-B*40:02|  55.56 (5/9)| 29.17 (7/24)

```
Rscript create_table_tmh_binders_mhc.R mhc1
Rscript create_table_tmh_binders_mhc.R mhc21
```

### `table_f_tmh.latex`

`[target]_coincidence.csv` must be present

`parameter`|`[target]
-----------|---------
n_spots    |1230
n_tmhs     |123
%TMH       |10

```
Rscript create_table_f_tmh.R
```

