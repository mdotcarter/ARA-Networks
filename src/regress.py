import numpy as np
import nibabel as nb

if __name__ == "__main__":

    inimg = nb.load('raw_roi_timecorr_mcf.nii.gz')
    data = inimg.get_data().astype(np.float64)

    global_mask = (nb.load('global-roi-epi.nii.gz').get_data() > 0)
    wm_mask = (nb.load('wm-roi-epi.nii.gz').get_data() > 0)
    csf_mask = (nb.load('csf-roi-epi.nii.gz').get_data() > 0)

    global_sig = data[global_mask].mean(0)
    wm_sig = data[wm_mask].mean(0)
    csf_sig = data[csf_mask].mean(0)

    # reshape buisness is needed because of shape returned by mean
    X = global_sig.reshape(global_sig.shape[0], -1)
    X = np.hstack((X, wm_sig.reshape(wm_sig.shape[0], -1)))
    X = np.hstack((X, csf_sig.reshape(csf_sig.shape[0], -1)))

    Y = data[global_mask].T
    B = np.linalg.inv(X.T.dot(X)).dot(X.T).dot(Y)
    R = Y - X.dot(B)

    data[:] = 0
    data[global_mask] = R.T

    outimg = nb.Nifti1Image(data, header=inimg.get_header(), affine=inimg.get_affine())
    outimg.to_filename('raw_roi_timecorr_mcf_res.nii.gz')
