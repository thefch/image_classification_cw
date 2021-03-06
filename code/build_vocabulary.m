% % Based on James Hays, Brown University
% 
% %This function will sample SIFT descriptors from the training images,
% %cluster them with kmeans, and then return the cluster centers.
% 
 function vocab = build_vocabulary( image_paths, VOCAB_SIZE,STEP_SIZE,COLORSPACE,BIN_SIZE,USE_PHOW,USE_NORM)
% % The inputs are images, a N x 1 cell array of image paths and the size of 
% % the vocabulary.
% 
% % The output 'vocab' should be vocab_size x 128. Each row is a cluster
% % centroid / visual word.
% 
% %{ 
% Useful functions:
% [locations, SIFT_features] = vl_dsift(img) 
%  http://www.vlfeat.org/matlab/vl_dsift.html
%  locations is a 2 x n list list of locations, which can be thrown away here
%   (but possibly used for extra credit in get_bags_of_sifts if you're making
%   a "spatial pyramid").
%  SIFT_features is a 128 x N matrix of SIFT features
%   note: there are step, bin size, and smoothing parameters you can
%   manipulate for vl_dsift(). We recommend debugging with the 'fast'
%   parameter. This approximate version of SIFT is about 20 times faster to
%   compute. Also, be sure not to use the default value of step size. It will
%   be very slow and you'll see relatively little performance gain from
%   extremely dense sampling. You are welcome to use your own SIFT feature
%   code! It will probably be slower, though.
% 
% [centers, assignments] = vl_kmeans(X, K)
%  http://www.vlfeat.org/matlab/vl_kmeans.html
%   X is a d x M matrix of sampled SIFT features, where M is the number of
%    features sampled. M should be pretty large! Make sure matrix is of type
%    single to be safe. E.g. single(matrix).
%   K is the number of clusters desired (vocab_size)
%   centers is a d x K matrix of cluster centroids. This is your vocabulary.
%    You can disregard 'assignments'.
% 
%   Matlab has a build in kmeans function, see 'help kmeans', but it is
%   slower.
% %}

N = size(image_paths, 1);
feats = cell(1, size(image_paths, 1));
STEP_SIZE = 10;
for ii=1:N
    % debugging
%     if (mod(ii,200)==0)
% %          fprintf(" %d \n",ii);
%     end
    
    I = imread(image_paths{ii});
     
    if(USE_PHOW)
        [~,features] = get_phow(I,COLORSPACE,STEP_SIZE);    
    else
        if (COLORSPACE == "GRAYSCALE")
            img = im2single(rgb2gray(I));
        else
            img = get_color_values(I,COLORSPACE);
        end
        [~, features] = vl_dsift(img, 'Fast', 'Step', STEP_SIZE);
        features = single(features);
    end
        
    % normalize features
    if(USE_NORM)
        tmp = sqrt(sum(features.^2, 2));
        features = features ./ repmat(tmp, [1 size(features,2)]);
    end

    feats{ii} = features;
end
    
% cluster features into a vocabulary of visual words
% it will cluster the features into groups, each group represents different
% class
[centers, ~] = vl_kmeans(cell2mat(feats), VOCAB_SIZE);
vocab = single(centers');
end
 
% % Load images from the training set. To save computation time, you don't
% % necessarily need to sample from all images, although it would be better
% % to do so. You can randomly sample the descriptors from each image to save
% % memory and speed up the clustering. Or you can simply call vl_dsift with
% % a large step size here, but a smaller step size in make_hist.m. 
% 
% % For each loaded image, get some SIFT features. You don't have to get as
% % many SIFT features as you will in get_bags_of_sift.m, because you're only
% % trying to get a representative sample here.
% 
% % Once you have tens of thousands of SIFT features from many training
% % images, cluster them with kmeans. The resulting centroids are now your
% % visual word vocabulary.