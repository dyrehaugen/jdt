# ~/zjul/corona/wrld/jmh/src/jR0.jl   Sensitivity  
# 200504 006
# 006 : differential data
#      : gtx = dgamma(8.4, 3.8) # Default Discrete Gamma Distribution
#      : Need to change sensitivity settings accordingly !
#      : Identify 8.4/3.8 on plots and files
#
# Adapted to joint processing, i.e. after up.all src/jcor.jl and src/jdfs.jl 
# Based on       ~/zjul/corona/R0/jR0td.jl
# Again Based on ~/zr/R0/jR0.R and jtd.R
#
# https://github.com/JuliaStats/Distributions.jl/blob/8bdcda68f903cf377ce37ee4540a3e4d936877e1/src/samplers/multinomial.jl#L53
# https://discourse.julialang.org/t/distributions-jl-using-a-custom-random-number-generator/5106
#

#

using CSV, Missings, DataFrames, Distributions, RandomNumbers, Printf, Plots
println("running jR0: reading data ...")
df_cfm            = CSV.read("dfs/df_cfm.csv")
df_cfm_100        = CSV.read("dfs/df_cfm_100.csv")
df_dcfm           = CSV.read("dfs/df_dcfm.csv")
df_dcfm_100       = CSV.read("dfs/df_dcfm_100.csv")
df_dcfm_100mv     = CSV.read("dfs/df_dcfm_100mv.csv")
#df = df_cfm_100    # 005
#df = df_dcfm_100   # 006 Differential 
df = df_dcfm_100mv  # 006 Moving Average
ths = "100"
updated  = @sprintf("%s", last(df_cfm.Date))
plotstring = "Confirmed Cases"

function dgamma(mid, std) # gt Discretized Gamma distribution 
    midv = mid  #3.0
    stdv = std  #1.5
    tmax = ceil(midv+10*stdv)
    a = midv*midv/(stdv*stdv)
    s = stdv*stdv / midv
    gd=Gamma(a,s)
    tscale = range(0.5, stop=13.5, step=1)
    gtg = zeros(size(tscale)[1])
    for i in 2:size(gtg)[1] gtg[i] = cdf(gd,tscale[i])-cdf(gd,tscale[i-1]) end
    return gtg
end # function dgamma

function R0( gt, ep)
    Tmax = length(ep)
    nsim = 100
    q = [0.025, 0.975]
    
    gtpad = gt
    if length(gtpad) < Tmax gtpad = vcat(gtpad, zeros(Tmax-length(gtpad))) end
    
    P = zeros(Tmax, Tmax)
    p = zeros(Tmax, Tmax)
    ms  = Matrix{Float64}[]
    ms0 = zeros(Tmax, nsim)
    for s in 1:Tmax push!(ms, ms0) end
    
    # Loop on epidemic duration:
    for s in 2:Tmax
        ms[s] = ms0
        if ep[s] > 0 
            gttmp=convert(Array, view(gtpad, s:-1:1))
            wcs = ep[1:s].*gttmp[1:s]
            wcs = wcs./sum(wcs)
            pcs = wcs .* (ep[s]./ep[1:s])
            for i in 1:(s-1) if ep[i]==0 pcs[i] = 0.0 end end
            if ep[s] == 1 pcs[s] = 0.0 end
            P[1:s,s] = pcs
            p[1:s,s] = wcs
            nsims=zeros(s, nsim)

            for i in 1:nsim  nsims[1:s,i] = rand(Multinomial(convert(Int64,ep[s]), p[1:s,s])) end 
            ms[s][1:s,1:nsim] = ms[s-1][1:s,1:nsim] + nsims
        else
            P[1:s,s] .= 0.0
            p[1:s,s] .= 0.0        
            ms[s][1:s,1:nsim] = ms[s-1][1:s,1:nsim]
        end
    end
    
    #We now have enough data to compute R (from infection network P)
    #along with its 5% and 95% quantiles (from multiple simulations and p)
    # R.WT<-apply(P,1,sum)  # Hvorfor gir dim=2 korrekt resultat?
    rwt = mapslices(sum, P, dims = [2])
    rcr = rwt./(cumsum(gtpad[1:Tmax]))[Tmax:-1:1]
    if isnan(rcr[length(ep)])  rcr[length(ep)] = 0.0 end 
    
    #Simulated incidence at each time unit is the sum of all cases,
    #stored in the last element of multinom.sim list
    tnf   = ms[length(ep)]    
    rsm   = tnf./ep            # Belgium s06 ->NaN divisjon på 0 -> Glatte input data nødvendig.
    rsmcr = rsm./(cumsum(gtpad[1:Tmax]))[Tmax:-1:1]
    rsmcr[length(ep),:] = zeros(nsim)
    
    # Quantiles:
    qsm    = zeros(Tmax,2)
    qsmcr  = zeros(Tmax,2)
    for s in 1:Tmax
        if (ep[s] == 0) 
          rwt[s] <- 0
          rsm[s] <- 0
          rcr[s] <- 0
          rsmcr[s] <- 0
        end
        qsm[s,:]   = quantile(rsm[s,:], q)
        qsmcr[s,:] = quantile(rsmcr[s,:], q)
    end
    
    # Confidence Interval:
    # multinomial simulations at each time step with the expected value of R.
    correct=true
    cint = zeros(Tmax,2) # colnames?
    if correct == true
        R = rcr
        cint = qsmcr
    else
        R =rwt
        cint = qsm
    end
    
    # Theoretical Predictions:
    pred = vcat(ep, gt)
    for i in 2:length(ep)+length(gt) pred[i]=0.0 end
    for s in 1:Tmax
        pred[s:s+length(gt)-1] = pred[s:s+length(gt)-1] + R[s] .* ep[s] * gt
    end
    pred = pred[1:Tmax]
    
return R, pred, cint
end # function R0

# MAIN:

df_R0    = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
df_Pred  = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
df_Clow  = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
df_Chgh  = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
mtxCint =Array{Tuple{Union{Missing,Float64},Union{Missing,Float64}},2}(undef, size(df))
for i in 1:size(mtxCint)[1] for j in 1:size(mtxCint)[2] mtxCint[i,j] = (missing, missing) end end
df_Cint = DataFrame(mtxCint, names(df))

#gtx = dgamma(3.0, 1.5) # Default Discrete Gamma Distribution
gtx = dgamma(8.4, 3.8) # Default Discrete Gamma Distribution 
# COUNTRY LOOP:
for j in 1:size(df)[2]
    cname=names(df)[j]
    epx = dropmissing(df, cname)[:,j]
    println(j," ", cname," ", sum(epx), " ",   length(epx))
    R, pred, cint = R0(gtx,epx)
    for i in 1:length(R)-1      df_R0[i,j] = R[i] end
    for i in 1:length(pred)   df_Pred[i,j] = pred[i] end
    for i in 1:size(cint)[1]-1  df_Clow[i,j] = cint[i,1] end
    for i in 1:size(cint)[1]-1  df_Chgh[i,j] = cint[i,2] end
    for i in 1:size(cint)[1]-1  df_Cint[i,j] = (cint[i,1], cint[i,2]) end        
end

CSV.write("dfs/df_R0.csv", df_R0)
CSV.write("dfs/df_Pred.csv", df_Pred)
CSV.write("dfs/df_Clow.csv", df_Clow)
CSV.write("dfs/df_Chgh.csv", df_Chgh)
CSV.write("dfs/df_Cint.csv", df_Cint)

# SENSITIVITY
println("jR0: Running Sensitivity Analysis for Norway ...")
j=4 # Country = Norway
cname=names(df)[j]                                                                                             
epx = dropmissing(df, cname)[:,j];                                                                              
println(j, cname," ", sum(epx), " ", length(epx))
# Mean Value:
s  = 1.5
mlist  = [ 2.5, 3.0, 3.5, 4.0, 5.0, 7.0];
mlistsym = [Symbol(@sprintf("m=%s", mlist[i])) for i in 1:length(mlist)];
df_R0SM = DataFrame(Array{Union{Missing, Float64}}(missing,(size(df)[1],length(mlist))), mlistsym);
for j in 1:length(mlist)
    gtx = dgamma(mlist[j], s) 
    R, pred, cint = R0(gtx,epx) 
    for i in 1:length(R)-1      df_R0SM[i,j] = R[i] end
end
# Standard Deviation:
m  = 3.5
slist  = [ 0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.0];
slistsym = [Symbol(@sprintf("s=%s", slist[i])) for i in 1:length(slist)];
df_R0SS = DataFrame(Array{Union{Missing, Float64}}(missing,(size(df)[1],length(slist))), slistsym);
for j in 1:length(slist)
    gtx = dgamma(m, slist[j]) 
    R, pred, cint = R0(gtx,epx) 
    for i in 1:length(R)-1      df_R0SS[i,j] = R[i] end
end
# Write:
CSV.write("dfs/df_R0SM.csv", df_R0SM)
CSV.write("dfs/df_R0SS.csv", df_R0SS)

# PLOTS:
println("jR0: Generating Plots ...")
mtxR0 = Matrix(df_R0)
labels1 = String[]
for i in 1:length(names(df_R0)) push!(labels1, String(names(df_R0)[i])) end
labels = reshape(labels1,1,:)
nmlast = [findfirst( x-> ismissing(x), mtxR0[:,i])-1 for i in 1:size(mtxR0)[2]]

plot(mtxR0, label = labels,
     legend=:outertopright,
     ylabel = "Effective Reproduction Number (R)",
     xlabel = "Days since first "*ths*" cases\nEnd of data: "*updated, xguidefontsize=8,
     title  = "Corona 2020\n(4)"*plotstring*" -Selected Countries")
savefig("figs/cfm_04.png")

plot(10:size(mtxR0)[1],mtxR0[10:end,:], label = labels,
     legend=:outertopright,
     ylabel = "Effective Reproduction Number (R)",
     xlabel = "Days since first "*ths*" cases\nEnd of data: "*updated, xguidefontsize=8,
     annotations=([(nmlast[i], mtxR0[nmlast[i],i],text(labels[i][1:2], :left, 8)) for i in 1:length(nmlast)]),
     title  = "Corona 2020\n(5)"*plotstring*" -Selected Countries")

savefig("figs/cfm_05.png")

plot(30:size(mtxR0)[1],mtxR0[30:end,:], label = labels,
     legend=:outertopright,
     ylabel = "Effective Reproduction Number (R)",
     xlabel = "Days since first "*ths*" cases\nEnd of data: "*updated, xguidefontsize=8,
     annotations=([(nmlast[i], mtxR0[nmlast[i],i],text(labels[i][1:2], :left, 8)) for i in 1:length(nmlast)]),
     title  = "Corona 2020\n(6)"*plotstring*" -Selected Countries")
savefig("figs/cfm_06.png")

# Plot Sensitivity:
mtxR0SM = Matrix(df_R0SM)
labels1 = String[]
for i in 1:length(names(df_R0SM)) push!(labels1, String(names(df_R0SM)[i])) end
labels = reshape(labels1,1,:)
nmlast = [findfirst( x-> ismissing(x), mtxR0SM[:,i])-1 for i in 1:size(mtxR0SM)[2]]    
plot(30:size(mtxR0SM)[1],mtxR0SM[30:end,:],
     label = labels,
     legend=:outertopright,
     ylabel = "Effective Reproduction Number (R)",
     xlabel = "Days since first "*ths*" cases\nEnd of data: "*updated, xguidefontsize=8,
     # annotations=([(nmlast[i], mtxR0SM[nmlast[i],i],text(labels[i][1:2], :left, 6)) for i in 1:length(nmlast)]),      
     title  = "Corona 2020\n(1)"*plotstring*" -Sensitivity R0 Norway")
savefig("figs5/R0SM.png")                                                                                  

mtxR0SS = Matrix(df_R0SS)
labels1 = String[]
for i in 1:length(names(df_R0SS)) push!(labels1, String(names(df_R0SS)[i])) end
labels = reshape(labels1,1,:)
nmlast = [findfirst( x-> ismissing(x), mtxR0SS[:,i])-1 for i in 1:size(mtxR0SS)[2]]
plot(30:size(mtxR0SS)[1],mtxR0SS[30:end,:],
     label = labels,
     legend=:outertopright,
     ylabel = "Effective Reproduction Number (R)",
     xlabel = "Days since first "*ths*" cases\nEnd of data: "*updated, xguidefontsize=8,
     # annotations=([(nmlast[i], mtxR0SS[nmlast[i],i],text(labels[i][1:2], :left, 8)) for i in 1:length(nmlast)]),      
     title  = "Corona 2020\n(6)"*plotstring*" -Sensitity Norway")
savefig("figs5/R0SS.png")
println("jR0: Finished")

# EOF 
