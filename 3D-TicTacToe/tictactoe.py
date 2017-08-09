import numpy as np
import cProfile
import time
class Cube:
  def __init__(self,size):
    self.size = size
    self.magic_cube = np.zeros((3,3,3))
    self.cube = np.copy(self.magic_cube)
    self.points = []
    self.corner_points =[]
    self.face_center = []
    self.rev_map = {}
    self._make_cube(size)
    self.neg_exception = set()
    self.pos_exception = set()
    self.populate_exception(size)
    print("Cube Generated. The 11 Surfaces are: ")
    self.print_11_surfaces(self.size)

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
          entry = self._fill_entry(i,j,k,size)
          point = tuple([i,j,k])
          self.magic_cube[i][j][k] = entry
          self.points.append(point)
          if( (i==0 or i==2) and (j==0 or j==2) and (k==0 or k==2)):
            self.corner_points.append(point)
          elif ( (j==1 and k==1) or (i==1 and j==1) or (k==1 and j==1)):
            self.face_center.append(point)
          self.rev_map[entry] = point

  def _is_collinear(self,p1,p2,p3):
    
    if(p1==p2 or p1==p3 or p2==p3): return False
    p1 = np.array(p1)
    p2 = np.array(p2)
    p3 = np.array(p3)
    return (np.array_equal(2*p1,p2+p3) or np.array_equal(2*p2,(p1+p3)) or np.array_equal(2*p3,(p1+p2)) )

  def populate_exception(self,size):
    assert (size == 3), "Only works if cube is 3x3x3"
    magic_sum = size*(size**3+1)/2
    self.magic_sum = magic_sum
    for p1 in self.points:
      for p2 in self.points:
        for p3 in self.points:
          if (not (p1==p2 or p2==p3 or p3==p1)):
            sum = self.magic_cube[tuple(p1)] + self.magic_cube[tuple(p2)] + self.magic_cube[tuple(p3)]
            if not self._is_collinear(p1,p2,p3):
              if sum == magic_sum:
                self.neg_exception.add(frozenset([p1,p2,p3]))
            else:
              if sum != magic_sum:
                self.pos_exception.add(frozenset([p1,p2,p3]))

  def print_plane(self,index,val):
    if(index==1):
      for j in range(3):
        for k in range(3):
          print(int(self.magic_cube[val][j][k]),end=' ')
        print("")
    elif(index==2):
      for i in range(3):
        for k in range(3):
          print(int(self.magic_cube[i][val][k]),end=' ')
        print("")        
    else:
      for i in range(3):
        for j in range(3):
          print(int(self.magic_cube[i][j][val]),end=' ')
        print("")        
     
  def print_11_surfaces(self,size):
    assert (size==3), "Only works fif cube is 3x3x3"
    print ('Top Surface')
    self.print_plane(1,0)
    print ('Middle X-Y Surface')
    self.print_plane(1,1)
    print ('Bottom Surface')
    self.print_plane(1,2)
    print ('Left Surface')
    self.print_plane(3,0)
    print ('Middle Y-Z Surface')
    self.print_plane(3,1)
    print ('Right Surface')
    self.print_plane(3,2)
    print ('Back Surface')
    self.print_plane(2,0)
    print ('Middle X-Z Surface')
    self.print_plane(2,1)
    print ('Front Surface')
    self.print_plane(2,2)
    print ('Diagonal 1 Surface')
    for i in range(3):
      for j in range(3):
        print(int(self.magic_cube[i][j][j]),end=' ')
      print("")
    
    print ('Diagonal 2 Surface')
    for i in range(3):
      for j in range(3):
        print(int(self.magic_cube[i][j][2-j]),end=' ')
      print("")
    
class Game:
  # there are two players:
  # player 1
  # player 2

  def __init__(self,size):
    self.cube = Cube(size)
    self.size = size
    self.cur_player = 1
    self.is_finished = False
    self.moves = [[],[]]
    self.total_moves = 0
    self.winner = None # 0-> Draw , 1-> player 1, 2-> player 2
    self.points = [0,0]

  # Make a move p (which is a coordinate tuple) and return true if move is valid and game is not finished
  # else return false
  def is_valid_move(self,p):
    return ((not self.is_end()) and self.cube.cube[p] == 0 and not self.is_finished)

  def move(self,p):
    if self.is_valid_move(p):
      if self.check_reward_condition(p,self.cur_player):
        self.points[self.cur_player-1] += 1
      self.cube.cube[p]=self.cur_player
      self.moves[self.cur_player-1].append(p)
      self.cur_player = self.cur_player%2 + 1
      self.total_moves += 1
 
  def is_end(self):
    if self.is_finished:
      return True
    if self.total_moves >= 20:
      self.is_finished = True
      if self.points[0] > self.points[1]:
        self.winner = 1
      elif self.points[1] > self.points[0]:
        self.winner = 2
      else:
        self.winner = 0
      return True
    return False

  # Checks if the points p1 ,p2 ,p3 make a line that fetches points
  def _correct_line(self,p1,p2,p3):
    cube = self.cube
    if cube._is_collinear(p1,p2,p3):
      if (cube.magic_cube[p1]+cube.magic_cube[p2]+cube.magic_cube[p3] == cube.magic_sum):
        if (frozenset([p1,p2,p3]) not in cube.neg_exception):
          return True
      elif(frozenset([p1,p2,p3]) in cube.pos_exception):
        return True
    return False

  # check if the given move results in a win for player.
  # return true if it is a winning move
  def check_reward_condition(self,p,player):
    if self.is_valid_move(p):
      prev_moves = self.moves[player-1]
      for move_1 in prev_moves:
        for move_2 in prev_moves:
          if(move_1 != move_2):
            if self._correct_line(move_1,move_2,p):
              return True
    return False

  # finds the third point in the cube give two points p1 and p2
  def _find_collinear_point(self,p1,p2):
    p1_ = np.array(p1)
    p2_ = np.array(p2)
    possible = [np.asarray((p1_+p2_)/2,dtype=np.int32),(2*p1_) - p2_,(2*p2_) - p1_]
    for p in possible:
      if (self.cube._is_collinear(p1,p2,tuple(p)) and np.all(p < 3) and np.all(p>=0)): 
        return tuple(p)
    return None

  # return rewarding move for a player p if it exists, else return None
  def find_rewarding_move(self,player):
    assert player in [1,2], "Player should be either 1 or 2"
    prev_moves = self.moves[player-1]
    for move_1 in prev_moves:
      for move_2 in prev_moves:
        if(move_1 != move_2):
          #needed_move = self.cube.magic_sum - (self.cube.magic_cube[move_1] + self.cube.magic_cube[move_2])
          #if(needed_move > 0 and needed_move <= self.size**3):
          #  move = self.cube.rev_map[needed_move]
          #  if(self.cube.cube[move] == 0 and self._correct_line(move_1,move_2,move)):
          #    return move
          move = self._find_collinear_point(move_1,move_2)
          if(move!=None and self.cube.cube[move] == 0 and self._correct_line(move_1,move_2,move)):
            return move
    return None
  
  def any_available_move(self):
    for p in self.cube.corner_points:
      if(self.is_valid_move(p)):
        return p
    for p in self.cube.face_center:
      if(self.is_valid_move(p)):
        return p
    for p in self.cube.points:
      if(self.is_valid_move(p)):
        return p
    return None

  def __str__(self):
    return self.cube.cube.__str__()

game = Game(3)

firstPlayer = int(input("\n\nWho Plays First? Computer (1) or Human (2)  "))
aiPlayer = firstPlayer

while(not game.is_end()):
  if(game.cur_player == (aiPlayer)):
    print('Computer Playing')
    if(game.is_valid_move((1,1,1))):
      game.move((1,1,1))
    else:
      p = game.find_rewarding_move(game.cur_player)
      if(p != None):
        game.move(p)
      else:
        p1 = game.find_rewarding_move( (game.cur_player%2 + 1))
        if(p1 != None):
          game.move(p1)
        else:
          p2 = game.any_available_move()
          game.move(p2)
  else:
    print(game)
    print("Human - %d\nAI - %d\n" %(game.points[firstPlayer-1],game.points[aiPlayer-1]))
    user_input = input(" Please enter the indices of your move (from 0): ")
    i, j, k = user_input.split(" ")
    i = int(i)
    j = int(j)
    k = int(k)
    if(game.is_valid_move((i,j,k))):
      game.move((i,j,k))
    else:
      print("Invalid Move, Please Retry")

print(game)
if(game.winner == aiPlayer):
  print('Computer Wins')
else:
  print('Human Wins')
