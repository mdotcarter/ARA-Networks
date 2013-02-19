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

    # perform regression on X, result is the residual
    Y = data[global_mask].T
    B = np.linalg.inv(X.T.dot(X)).dot(X.T).dot(Y)
    R = Y - X.dot(B)


    # filter the residual using rectangular bandpass 0.009 to 0.08 Hz
    hdr = inimg.get_header()
    TR = hdr["pixdim"][4]
    freq = np.fft.fftfreq(R.shape[0], d = TR).reshape(R.shape[0], -1)
    fft = np.fft.fft(R, axis = 0)

    filtcoef = np.logical_or(np.logical_and(np.greater(freq, 0.009),
                                            np.less(freq, 0.08)),
                             np.logical_and(np.greater(freq, -0.08),
                                            np.less(freq, -0.009))).astype(np.float64)
    filtmat = np.dot(filtcoef, np.ones([1, R.shape[1]]))
    filtered = np.real(np.fft.ifft(np.multiply(fft, filtmat), axis = 0))

    # place back into image
    data[:] = 0
    data[global_mask] = filtered.T

    outimg = nb.Nifti1Image(data, header=inimg.get_header(), affine=inimg.get_affine())
    outimg.to_filename('raw_roi_timecorr_mcf_res.nii.gz')
