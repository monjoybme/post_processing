import openslide as ops 
import numpy as np 
import cv2 
import glob
import os 
import matplotlib.pyplot as plt 

'''
Author: Simon Graham
Tissue Image Analytics Lab
Department of Computer Science, 
University of Warwick, UK.
'''

######################################################################################

# Overlay options
overlay_type = 'draw_boundary'   # choose from 'mask_overlay' and 'draw_boundary'
colour = 'green'  # choose from 'red', 'green' or 'blue'

if overlay_type == 'mask_overlay':
	alpha = 0.65  # parameter that controls transparency
	if colour == 'red':
		rgb = 0
	elif colour == 'green':
		rgb = 1
	elif colour == 'blue':
		rgb = 2


elif overlay_type == 'draw_boundary':
	line_thickness = 14 # how thick the boundaries appear
	if colour == 'red':
		rgb = (255,0,0)
	elif colour == 'green':
		rgb = (0,255,0) 
	elif colour == 'blue':
		rgb = (0,0,255)

######################################################################################

mask_ext = '.png'
wsi_ext = '.svs'

pathWsi = '/pathWsi/'
pathMask = '/pathMask/'
outPath = '/outPath/'

list_images = glob.glob(pathMask + '*' + mask_ext)
num_images = len(list_images)

for i in range(num_images):

	basename = os.path.basename(list_images[i])
	basename = basename.split('.')[0]

	mask = pathMask + basename + mask_ext
	mask = cv2.imread(mask, 0)
	mask_shape = mask.shape
	mask = cv2.resize(mask, (mask_shape[1],mask_shape[0]))

	im2, contours, hierarchy = cv2.findContours(mask, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

	rgb_mask = np.zeros([mask.shape[0],mask.shape[1],3])
	rgb_mask[:,:,rgb] = mask
	rgb_mask = rgb_mask.astype('uint8')


	wsi = pathWsi + basename + wsi_ext
	wsi = ops.OpenSlide(wsi)
	wsi_dimensions = wsi.level_dimensions

	factor_downsample = np.round(wsi_dimensions[0][0] / mask.shape[1],0)
	downsamples = wsi.level_downsamples
	
	downsamples_list = []
	for j in range(len(downsamples)):
		downsamples_list.append(int(downsamples[j])) 

	level = downsamples_list.index(int(factor_downsample)) # select level that the mask is saved at

	wsi_image = wsi.read_region((0,0), level, (wsi_dimensions[level][0], wsi_dimensions[level][1]))
	wsi_image = np.asarray(wsi_image)
	wsi_image = wsi_image[:,:,:3]  # use rgb channels
	wsi_image = wsi_image.astype('uint8')  # convert wsi_image to uint8- same data type as mask. Necessary for overlay

	if overlay_type == 'mask_overlay':
		# create two copies of the original image -- one for
		# the overlay and one for the final output image
		overlay = wsi_image.copy()
		output = rgb_mask.copy()
		# apply the overlay
		cv2.addWeighted(overlay, alpha, output, 1 - alpha, 0, output)
		# save the image with overlay
		plt.imsave(outPath + basename + mask_ext, output)

	elif overlay_type == 'draw_boundary':
		cv2.drawContours(wsi_image, contours, -1, rgb, line_thickness)
		# save the image with boundaries
		plt.imsave(outPath + basename + mask_ext, wsi_image)


