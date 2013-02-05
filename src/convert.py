import os
import nipype.interfaces.freesurfer as fs
import nipype.interfaces.utility as util
import nipype.pipeline.engine as pe

def pathfinder(subjectname, foldername):
    import os
    return os.path.join(foldername, subjectname)

if __name__ == "__main__":

    # Location of experiment file tree
    pwd = os.getcwd()
    experiment_dir =  os.path.join(pwd, 'experiment')

    # List of subject identifiers
    with open(os.path.join(experiment_dir, 'subject_list.txt'), 'r') as subject_file:
        subjects_list = filter(len, subject_file.read().split('\n'))

    print subjects_list

    # dicom and output data folder
    dicom_dir_name = os.path.join(experiment_dir, 'dicom')
    data_dir_name = os.path.join(experiment_dir, 'data')

    # source node for subjects
    infosource = pe.Node(interface=util.IdentityInterface(fields=['subject_id']),
                         name="infosource")
    infosource.iterables = ('subject_id', subjects_list)

    # node for conversion using FS DicomConvert
    dicom2nifti = pe.Node(interface=fs.DICOMConvert(), name="dicom2nifti")
    dicom2nifti.inputs.base_output_dir = data_dir_name
    dicom2nifti.inputs.file_mapping = [('nifti','*.nii'),('info','dicom.txt')]
    dicom2nifti.inputs.out_type = 'nii'
    dicom2nifti.inputs.subject_dir_template = '%s'

    # conversion pipeline
    conversion = pe.Workflow(name="conversion")
    conversion.base_dir = os.path.join(experiment_dir,'workingdir_conversion')

    # connect nodes and run
    conversion.connect([(infosource, dicom2nifti,[('subject_id', 'subject_id')]),
                        (infosource, dicom2nifti,[(('subject_id', pathfinder, dicom_dir_name),
                                                   'dicom_dir')]),
                        ])

    conversion.run(plugin='MultiProc', plugin_args={'n_procs' : 4})
