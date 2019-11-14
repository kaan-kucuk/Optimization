using JuMP, Clp, Printf

d = [40 60 75 25]                   # monthly demand for boats

m = Model(with_optimizer(Clp.Optimizer))

@variable(m, 0 <= x[1:4] <= 40)       # boats produced with regular labor
@variable(m, y[1:4] >= 0)             # boats produced with overtime labor
@variable(m, h[1:5] >= 0)             # boats held in inventory
@variable(m, j[1:5] >= 0)             # Demand not meet
@variable(m, cp[1:4] >= 0)
@variable(m, cn[1:4] >= 0)
@variable(m, p[1:4] >=0)              # boats  made last quarter
@constraint(m, p[1] == 50)            # boats  made pre Q1
@constraint(m, h[1] == 10)            #inventory start
@constraint(m, h[5] >= 10)            #inventory end
@constraint(m, j[1] == 0)
@constraint(m, j[5] <= 0)
@constraint(m, [i in 1:4], h[i]-j[i]+x[i]+y[i]==d[i]+h[i+1]-j[i+1])     # conservation of boats
@constraint(m,[i in 1:4],x[i]+y[i]-p[i]==cp[i]-cn[i])
@constraint(m,[i in 2:4],p[i]==x[i-1]+y[i-1])                           # total production
@objective(m, Min, 400*sum(x) + 450*sum(y) + 20*sum(h) + 400*sum(cp) + 500*sum(cn)+100*sum(j))         # minimize costs

optimize!(m)
@printf("-----------------------------------------------\n ")
@printf("Boats to build regular labor: %d %d %d %d\n ", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n ", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("Inventories: %d %d %d %d %d\n ", value(h[1]), value(h[2]), value(h[3]), value(h[4]), value(h[5]))
@printf("Inventory Backloging: %d %d %d %d %d\n ", value(j[1]), value(j[2]), value(j[3]), value(j[4]), value(j[5]))
@printf("Pre Prodution Total: %d %d %d %d\n ", value(p[1]), value(p[2]), value(p[3]), value(p[4]))
@printf("C pozitive: %d %d %d %d\n ", value(cp[1]), value(cp[2]), value(cp[3]), value(cp[4]))
@printf("C negative: %d %d %d %d\n ", value(cn[1]), value(cn[2]), value(cn[3]), value(cn[4]))
@printf("-----------------------------------------------\n")
@printf("Objective cost: %f\n", objective_value(m))
