import numpy as np

class Cube:
  def __init__(self,size):
    self.size = size
    self.magic_cube = np.zeros((3,3,3))
    self.cube = np.copy(self.magic_cube)
    self._make_cube(size)
    self.points = []
    self.neg_exception = set()
    self.pos_exception = set()

    for i in range(size):
      for j in range(size):
        for k in range(size):
          self.points.append((i,j,k))

    self.populate_exception(size)

  def _fill_entry(self,i,j,k,size):
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

  def _make_cube(self,size):
    for i in range(size):
      for j in range(size):
        for k in range(size):
          self.magic_cube[i][j][k] = self._fill_entry(i,j,k,size)

  def _is_collinear(self,p1,p2,p3):
    if(np.allclose(p1,p2) or np.allclose(p1,p3) or np.allclose(p2,p3)): return True
    p1 = np.array(p1)
    p2 = np.array(p2)
    p3 = np.array(p3)
    v1 = p1-p2
    v2 = p1-p3
    v1 = v1/np.linalg.norm(v1)
    v2 = v2/np.linalg.norm(v2)
    dot = np.abs(np.dot(v1,v2))
    return np.isclose(dot,1)

  def populate_exception(self,size):
    assert (size == 3), "Only works if cube is 3x3x3"
    magic_sum = size*(size**3+1)/2
    for p1 in self.points:
      for p2 in self.points:
        for p3 in self.points:
          if (not (np.allclose(p1,p2) or np.allclose(p2,p3) or np.allclose(p3,p1))):
            sum = self.magic_cube[tuple(p1)] + self.magic_cube[tuple(p2)] + self.magic_cube[tuple(p3)]
            if not self._is_collinear(p1,p2,p3):
              if sum == magic_sum:
                self.neg_exception.add(frozenset([p1,p2,p3]))
            else:
              if sum != magic_sum:
                self.pos_exception.add(frozenset([p1,p2,p3]))