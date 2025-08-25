process merge_FASTQ_R1
{
    publishDir "${params.outdir}/", mode:'copy'
    container '882400076574.dkr.ecr.us-east-1.amazonaws.com/juniper-python:latest'
    cpus 8
    memory '16 GB'

    input:
    tuple(val(parent),val(embryo),val(biopsy),path(FASTQs))

    output:
    path("*.merged.fq.gz")

    script:
    """
    cat ${FASTQs} > ${parent}_${embryo}_${biopsy}.merged.R1.fastq.gz
    """
}

process merge_FASTQ_R2
{
    publishDir "${params.outdir}/", mode:'copy'
    container '882400076574.dkr.ecr.us-east-1.amazonaws.com/juniper-python:latest'
    cpus 8
    memory '16 GB'

    input:
    tuple(val(parent),val(embryo),val(biopsy),path(FASTQs))

    output:
    path("*.merged.fq.gz")

    script:
    """
    cat ${FASTQs} > ${parent}_${embryo}_${biopsy}.merged.R2.fastq.gz
    """
}

workflow
{
    FASTQ_1 = Channel.fromPath(params.input_csv).splitCsv(header: true,sep: ",").map{
        row -> tuple(row.parent,row.embryo,row.biopsy,file(row.fastq_1))
    }
    FASTQ_2 = Channel.fromPath(params.input_csv).splitCsv(header: true,sep: ",").map{
        row -> tuple(row.parent,row.embryo,row.biopsy,file(row.fastq_2))
    }
    //FASTQ_1.view()
    //FASTQ_2.view()

    Grouped_FASTQ_1 = FASTQ_1.groupTuple(by:[0,1,2]) 
    Grouped_FASTQ_2 = FASTQ_2.groupTuple(by:[0,1,2])
    merge_FASTQ_R1(Grouped_FASTQ_1)
    merge_FASTQ_R2(Grouped_FASTQ_2)

}