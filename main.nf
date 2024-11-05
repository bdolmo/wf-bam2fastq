#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Define parameters for input/output directories and maximum CPU threads
params.bam_dir = "/home/minion/Desktop/wf-template/test_data"   // Path where BAM files are located
params.out_dir = "/home/minion/Desktop/output_test"             // Output directory for FASTQ files
params.threads = 12                                              // Number of threads for samtools

// Create a channel for BAM files
bam_files = Channel.fromPath("${params.bam_dir}/*.bam")

// Track converted files
converted_files = []

process bamToFastq {
    container 'quay.io/biocontainers/samtools:1.10--h2e538c0_3'
    // publishDir params.out_dir
    tag "${bam_file.simpleName}"                                // Tag the process with the BAM filename
    cpus params.threads                                         // Set the number of threads per process
    memory '2 GB'

    input:
    path bam_file                                               // Automatically takes each BAM file from the channel

    output:
    path "${bam_file.simpleName}.fastq.gz"     // Save output to the specified directory and track paths

    script:
    """
    echo "Processing ${bam_file}..."
    samtools fastq -T MM,ML ${bam_file} | gzip > ${bam_file.simpleName}.fastq.gz
    """
}


process deleteFastq {
    input:
    path fastq_file

    script:
    """
    echo "Deleting ${fastq_file}..."
    rm -f ${fastq_file}
    """
}


// Workflow definition
workflow {
    fastq_files = bam_files | bamToFastq                        // Run bamToFastq on each BAM file

    // Collect all resulting FASTQ files into a single list
    fastq_files
        .collectFile(storeDir: params.out_dir, name: 'merged.fastq.gz')
        .set { merged_fastq_files }


    // Delete individual FASTQ files after merging
    fastq_files | deleteFastq

    // // Generate the WorkflowResult output as a JSON file
    // result = generateWorkflowResult(fastq_files)
    // result.view() // Display result on the console (for debugging)
    // result.save("$params.out_dir/workflow_result.json")
}

workflow.onComplete {
    println "Workflow execution completed successfully."
}

// Function to generate WorkflowResult JSON structure
// def generateWorkflowResult(fastq_files) {
//     def workflow_pass = fastq_files.map{it.exists()}    // Check if all files were created successfully

//     println workflow_pass

//     def converted_files = fastq_files.collect { it.toString() } // Collect paths as strings

//     def result = [
//         workflow_pass   : workflow_pass,
//         converted_files : converted_files
//     ]
    
//     return Channel.value(result)
// }
