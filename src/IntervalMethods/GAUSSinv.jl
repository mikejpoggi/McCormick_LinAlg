#Based on det(A) ⊆ det(inv(A_c)*A)/ det(inv(A_c))
#This function estimates bounds on the determinate of an interval matrix
# by applying gaussian elimination following preconditioning
using LinearAlgebra, IntervalArithmetic

function gaussinvdet(A::Array{Interval{Float64}, 2}) where N
      Intzero::Interval = Interval(0.0,0.0)
      (n,m) = size(A)
      Am = map(x->(x.lo+x.hi)/2, A)# Midpoint Matrix for preconditioning
      Am_inv = inv(Am)
      detAm_inv = det(Am_inv)
      A_k = Am_inv * A #Preconditioning step
      A_kplus1 = copy(A_k)
      #This way is closer to paper's values
      for k = 1:(n-1) #From A NEW CRITERION TO GUARANTEE THE FEASIBILITY OF THE INTERVAL GAUSSIAN ALGORITHM*, A. FROMMERf AND G. MAYER
            for i = 1:n
                  for j = 1:n#Assume A is nxn
                        if 1<=i<=k && 1<=j<=n
                        elseif (k+1)<=i<=(k+n) && (k+1)<=j<=(k+n)
                              A_kplus1[i,j] -= (A_k[i,k]*A_k[k,j])/A_k[k,k]
                        else
                              A_kplus1[i,j] = 0
                        end
                  end
            end
            A_k = A_kplus1
      end
      detk::Interval = A_k[1,1]
      for i = 2:n
            detk *= A_k[i,i]
      end
      detk = detk / detAm_inv
      return detk
end

function gaussinvdet(A::Array{MC{N}, 2}) where N
      Intzero::Interval = Interval(0.0,0.0)
      B = map(x -> x.Intv, A)
      (n,m) = size(A)
      Am = map(x->(x.lo+x.hi)/2, B)# Midpoint Matrix for preconditioning
      Am_inv = inv(Am)
      detAm_inv = det(Am_inv)
      A_k = Am_inv * B #Preconditioning step
      A_kplus1 = copy(A_k)
      #This way is closer to paper's values
      for k = 1:(n-1) #From A NEW CRITERION TO GUARANTEE THE FEASIBILITY OF THE INTERVAL GAUSSIAN ALGORITHM*, A. FROMMERf AND G. MAYER
            for i = 1:n
                  for j = 1:n#Assume A is nxn
                        if 1<=i<=k && 1<=j<=n
                        elseif (k+1)<=i<=(k+n) && (k+1)<=j<=(k+n)
                              A_kplus1[i,j] -= (A_k[i,k]*A_k[k,j])/A_k[k,k]
                        else
                              A_kplus1[i,j] = 0
                        end
                  end
            end
            A_k = A_kplus1
      end
      detk::Interval = A_k[1,1]
      for i = 2:n
            detk *= A_k[i,i]
      end
      detk = detk / detAm_inv
      return detk
end


#Using alternative interval arithmetic, this version not used
function gaussdinvdet(A::Array{Interval{Float64}, 2})
      Intzero::Interval = Interval(0.0,0.0)
      (n,m) = size(A)
      Am = map(x->(x.lo+x.hi)/2, A)# Midpoint Matrix for preconditioning
      Am_inv = inv(Am)
      detAm_inv = det(Am_inv)
      A_d = Am_inv * A #Preconditioning step

      for i = 1:n #Assume A is nxn. No row swapping as of yet
            if Ad[i,i] != Intzero #As long as the current pivot isn't 0
                  pivotval = Ad[i,i];
                  for row=i:(m-1) #Row subtracts pivot from below to make it a true pivot column
                        if Ad[row+1,i] != 0#if the next col isnt 0
                              Ad[row+1,:] = dualsub(Ad[row+1,:], Ad[row+1,i] * dualdiv(Ad[i,:], pivotval)); #Translates to newrow = oldrow - (pivot scaled to elimate pivot column)
                        end #Using dual from T. Nirmala1, D. Datta2, H.S. Kushwaha3, K. Ganesan4 §
                  end
            end
      end

      detd::Interval = Ad[1,1]
      for i = 2:n
            detd *= Ad[i,i]
      end
      detd = detd / detAm_inv
      return detd
end
