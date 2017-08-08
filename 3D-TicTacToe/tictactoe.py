def _fill_entry(i,j,k,size):
  i += 1
  j += 1
  k += 1
  if (size%2 == 1):
    a = (i - j + k - 1 + (3*size) )%size
    b = (i - j - k + (3*size) )%size
    c = (i + j + k - 2 + (3*size) )%size
    return ( a*size*size + b*size + c + 1)
  if (size%4 == 0):
    i_ = i>size/2
    j_ = j>size/2
    k_ = k>size/2
    F = (i+j+k+i_+j_+k_)
    if (F==1):
      return ((i-1)*size*size + (j-1)*size + k)
    else:
      return ((i_-1)*size*size + (j_-1)*size + k_)
  if (size%4 == 2):
    raise Exception('Not yet implement for size of form 4k+2.')

def make_cube(size):
  cube = [[[0 for _ in range(size)] for _ in range(size)] for _ in range(size)]
  for i in range(size):
    for j in range(size):
      for k in range(size):
        cube[i][j][k] = _fill_entry(i,j,k,size)
  return cube

