function output =  CleanVolume3D(input)


[xs ys zs] =size(input);



largestobject = false(xs,ys,zs);
object = bwconncomp(input)
numPixels = cellfun(@numel,object.PixelIdxList);
[largest,idx] = max(numPixels);


   largestobject(object.PixelIdxList{idx}) = 1;
  
   output = largestobject;
end
