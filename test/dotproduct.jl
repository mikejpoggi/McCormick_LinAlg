#@test lines for XSCAL etc
#Meant to be the easiest test file to make
@testset "Test DOT" begin
mctol = 1E-4
m = MC{2}(2.0, 3.0, IntervalType(1.0,4.0),
             seed_gradient(Float64,1,2), seed_gradient(Float64,1,2), false)
mscal = DOT(m, m)
@test mscal.cc = 4.0
@test mscal.cv = 6.0
@test mscal.Intv.lo = 2.0
@test mscal.Intv.lo = 8.0
end
