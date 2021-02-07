function template()
    tpl= mt"""#!/bin/sh
    # embedded options to qsub - start with #PBS
    # -- Name of the job ---
    #BSUB -J %SERVER_ID
    # �~@~S- specify queue --
    #BSUB -q {{cluster}}
    ### -- ask for number of cores (default: 1) --
    #BSUB -n {{cores}}
    ### -- specify that the cores must be on the same host --
    #BSUB -R "span[hosts=1]"
    ### -- specify that we need 2GB of memory per core/slot --
    #BSUB -R "rusage[mem=8GB]"
    ### -- specify that we want the job to get killed if it exceeds 3 GB per core/slot --
    #BSUB -M 8GB
    ### -- set walltime limit: hh:mm --
    #BSUB -W 8:00
    ### -- set the email address --
    # please uncomment the following line and put in your e-mail address,
    # if you want to receive e-mail notifications on a non-default address
    #BSUB -u amraj@dtu.dk
    ### -- send notification at start --
    ##BSUB -B
    ### -- send notification at completion --
    ##BSUB -N
    ### -- Specify the output and error file. %J is the job-id --
    ### -- -o and -e mean append, -oo and -eo mean overwrite --
    #BSUB -o {{{workspace}}}/Output.out
    #BSUB -e {{{workspace}}}/Error.err

    export JULIA_NUM_THREADS={{cores}}
    export SERVER_ID=$SERVER_ID

    {{{command}}}
    """
    return tpl
end
