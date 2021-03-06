nextflow.enable.dsl = 2

process SCREEN_FOR_CONTAMINANTS {
    tag { pair_id }
    publishDir "${params.output_dir}/sendsketch", mode: 'copy', pattern: "${pair_id}.sendsketch.txt"

    input:
    tuple val(pair_id), path(contigs_file)

    output:
    path "${pair_id}_stain_genus_species.tsv"
    tuple val(pair_id), path("${pair_id}_contig.fa")
    path "${pair_id}.sendsketch.txt"

    script:
    """
    rename_fasta.py --input ${contigs_file} --output ${pair_id}_contig.fa --pre ${pair_id}_contig

    sendsketch.sh \
        in=${pair_id}_contig.fa \
        samplerate=0.1 \
        out=${pair_id}.sendsketch.txt

    # This process yields the main stdout for prokka
    sendsketch_to_prokka.py \
        ${pair_id}.sendsketch.txt \
        $projectDir/resources/gram_stain.txt \
        ${pair_id}_stain_genus_species.tsv

    """

    stub:
    """
    touch ${pair_id}_stain_genus_species.tsv
    touch ${pair_id}_contig.fa
    touch ${pair_id}.sendsketch.txt
    """
}
