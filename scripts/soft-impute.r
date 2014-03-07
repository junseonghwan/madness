# soft-impute.... blah
# la: lambda
# Z.0: initial Z_old in the algorithm
# X: data
# train.ind: observed entries
# epsilon: termination bound
soft.impute<-function(la, Z.0, X, train.ind, epsilon)
{
  m<-dim(X)[1]
  n<-dim(X)[2]
  Z.old<-Z.0
  W<-matrix(0, m, n)
  W[train.ind]<-X[train.ind]
  iter<-0
  while (TRUE)
  {
	W[!train.ind]<-Z.old[!train.ind]
	W.svd<-svd(W)
	W.svd$d[(W.svd$d - la) < 0]<-0 # soft-thresholding
	Z.new<-W.svd$u%*%tcrossprod(diag(W.svd$d), W.svd$v) # get the new matrix
	diff<-sum((Z.new-Z.old)^2)
	diff<-diff/sum(Z.old^2)
	Z.old<-Z.new

	if (is.na(diff)) # 0/0 can occur => lambda is too big
	  break

	iter<-iter+1
	if (diff < epsilon) # terminate the while loop
	  break
  }

  ret<-list('Z'=Z.old, 'iter'=iter, 'err'=diff)
  
  return (ret)
}
