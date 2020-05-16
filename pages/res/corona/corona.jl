# ~/znb/corona/nb/corona.jl  -- downloaded from ~/znb/corona/nb/corona.ipynb                                                         
# 200515 004                                                                                                                   

#= working (notebook) directory: ~/znb/corona/nb
                                                                                                                         
We start out by getting the data running debian/linux bash shell:                                                              
cd ~/znb/corona/
$ clone https://github.com/bumbeishvili/covid19-daily-data                                                                     

# For later updating:
$ cd ~/znb/corona/covid19-daily-data
$ git pull origin

# These are the files we get:                                                                                                 
$ ls ~/znb/corona/covid19-daily-data                                                                                                        
misc  README.md  time_series_19-covid-Confirmed.csv  time_series_19-covid-Deaths.csv  time_series_19-covid-Recovered.csv       

# Returning to working (notebook) directory
$ cd ~/znb/corona/nb
Now we can look into the time series of confirmed cases, running Julia:                                                        
=#


using CSV, Missings, DataFrames, Dates,  Printf, Plots
using SpecialFunctions, Distributions, RandomNumbers

df_cfm_src = CSV.read("../covid19-daily-data/time_series_19-covid-Confirmed.csv");
first(df_cfm_src, 10)

names(df_cfm_src)[end]

last(df_cfm_src)

countries = df_cfm_src[:,2];

# Specify which countries to extract:
clist  = ["Argentina" "Belgium" "Brazil" "Norway" "Spain" "Sweden" "Thailand"]


# Extracting the epidemic data:
cindx = Array{Int64}(undef, length(clist))
cfm   = zeros(size(df_cfm_src)[2]-4, length(clist)); # Data starts in column 4
for i in 1:length(clist)
    indx = findall(x->x==clist[i], df_cfm_src[:,2])  
    cfm[:,i] = convert(Array, df_cfm_src[indx,5:end])
end
df_cfm = DataFrame(cfm)
for i in 1:length(clist)
     rename!(df_cfm, names(df_cfm)[i] => Symbol(clist[i])); 
end                  

last(df_cfm, 6)

# Converting the Dates:
colstring = Array{Union{Nothing, String}}(nothing, length(names(df_cfm_src))-4,2)
coldates  = Array{Date,length(names(df_cfm_src))-4}
for i in 1:length(names(df_cfm_src))-4 colstring[i,1] = String(names(df_cfm_src)[i+4])*"20" end #  adding 20 to get 2020  
colstring2=colstring
for i=1:length(colstring[:,1]) colstring2[i,1]=replace(colstring[i,1], "/" => "-") end
coldates=Date.(colstring2[:,1], Dates.DateFormat("mm-dd-yyyy"))
df_00 = DataFrame([coldates])
rename!(df_00, :x1 => :Date);

# Joining Dates and Data:
df_cfm = hcat(df_00, df_cfm);
# The Epidemic takes hold for these countries from late March
# To show the last week we use
last(df_cfm, 7)

CSV.write("dfs/df_cfm.csv", df_cfm)

plot(df_cfm[:,1], cfm,
     label = clist,
     legend=:outertopright, xrotation=45,
     title = "Corona 2020\nConfirmed Cases - Selected Countries")


savefig("figs/cfm_01.png")

th = 100;
# Finding first occurrence of more than 'th' confirmed cases
firsts = zeros(Int, size(df_cfm)[2]-1);
for j in 1:size(df_cfm)[2]-1 firsts[j] = findfirst(x->x>th, cfm[:,j]) end
firsts

# Extracting the data that is above the treshold:
mtx = Array{Union{Missing, Float64}}(missing,size(df_cfm)[1]-minimum(firsts)+1, size(df_cfm)[2]-1)
for j in 1:size(mtx)[2]
    for i in 1:size(cfm)[1]-firsts[j]+1   mtx[i,j] = cfm[firsts[j]-1+i,j] end
end
df_cfm_th = DataFrame(mtx)
for i in 1:length(clist)
    rename!(df_cfm_th, names(df_cfm_th)[i] => Symbol(clist[i]));
end
size(df_cfm_th)

first(df_cfm_th,7)

last(df_cfm_th,7)

CSV.write("dfs/df_cfm_th.csv", df_cfm_th)

# PLOTTING:
    updated = @sprintf "%10s" df_cfm.Date[end]
    
plot(mtx,
     label = clist,
     legend=:outertopright, 
     xlabel = "Days since 100th Case\nEnd of data: "*updated, xguidefontsize=8,
     title = "Corona 2020\nConfirmed Cases - Selected Countries")


savefig("figs/cfm_02.png")

# Differences
cfm_th = Matrix(df_cfm_th);
dcfm_th = diff(cfm_th, dims=1)


# 1: Check if zero:
for i = 1:size(dcfm_th)[1]
    for j = 1:size(dcfm_th)[2]-1
        if !ismissing(dcfm_th[i,j])
            if dcfm_th[i,j] == 0.0 && !ismissing(dcfm_th[i+1,j])
                dcfm_th[i,j]   = 0.5*dcfm_th[i+1,j]÷1 
                dcfm_th[i+1,j] = dcfm_th[i,j]+2*(dcfm_th[i+1,j]%1)
            end
         end
    end
end
dcfm_th

# 2: Check if negativ: (Norway!)                                                                                                    
for i = 1:size(dcfm_th)[1]
    for j = 1:size(dcfm_th)[2]-1
        if !ismissing(dcfm_th[i,j])
            if dcfm_th[i,j] < 0.0 && !ismissing(dcfm_th[i+1,j])
                dcfm_th[i,j]   = 0.5*(dcfm_th[i,j] + dcfm_th[i+1,j])÷1
                dcfm_th[i+1,j] = dcfm_th[i,j]
            end
         end
    end
end


df_dcfm_th = DataFrame(dcfm_th, names(df_cfm)[2:end])
CSV.write("dfs/df_dcfm_th.csv", df_dcfm_th)

# Moving average:                                                                                                                   
n=5
dcfm_thmv= Array{Union{Missing, Float64}}(missing,size(dcfm_th)[1]-(n-1), size(dcfm_th)[2])
vsm(vs,n) = [sum(@view vs[i:(i+n-1)])/n for i in 1:(length(vs)-(n-1))]
for j in 1:size(dcfm_th)[2]
    dcfm_thmv[:,j] = vsm(dcfm_th[:,j],5).÷1
end
df_dcfm_thmv = DataFrame(dcfm_thmv, names(df_cfm)[2:end])
CSV.write("dfs/df_dcfm_thmv.csv", df_dcfm_thmv)


# PLOTTING:
    updated = @sprintf "%10s" df_cfm.Date[end]
    
plot(dcfm_thmv,
     label = clist,
     legend=:outertopright, 
     xlabel = "Days since 100th Case\nEnd of data: "*updated, xguidefontsize=8,
     title = "Corona 2020\nDaily New Confirmed Cases - Selected Countries")


savefig("figs/cfm_03.png")

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


function dweibull(mid, std) # gt Discretized Weibull distribution 
    midv = mid  #8.4
    stdv = std  #3.8
    tmax = ceil(midv+10*stdv)
    #a = midv*midv/(stdv*stdv)
    a = 1.2785 * (midv/stdv) - 0.5004
    # s = stdv*stdv / midv
    s = midv / gamma(1 + ( 1/midv))
    gw=Weibull(a,s)
    tscale = range(0.5, stop=13.5, step=1)
    gtw = zeros(size(tscale)[1])
    for i in 2:size(gtw)[1] gtw[i] = cdf(gw,tscale[i])-cdf(gw,tscale[i-1]) end
    return gtw
end # function dweibull


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
df       = df_dcfm_thmv

df_R0    = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
df_Pred  = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
df_Clow  = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
df_Chgh  = DataFrame(Array{Union{Missing, Float64}}(missing,size(df)), names(df))
mtxCint =Array{Tuple{Union{Missing,Float64},Union{Missing,Float64}},2}(undef, size(df))
for i in 1:size(mtxCint)[1] for j in 1:size(mtxCint)[2] mtxCint[i,j] = (missing, missing) end end
df_Cint = DataFrame(mtxCint, names(df))

#gtx = dgamma(8.4, 3.8) # Default Discrete Gamma Distribution
gtx = dweibull(8.4, 3.8) # Default Discrete Weibull Distribution 
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


R = Matrix(df_R0)

plot(R,
     label = clist,
     legend=:outertopright, 
     xlabel = "Days since 100th Case\nEnd of data: "*updated, xguidefontsize=8,
     title = "Corona 2020\nReproduction Number R - Selected Countries")


savefig("figs/cfm_04.png")

R = Matrix(df_R0)

plot([20:size(R)[1]],R[20:end,:],
     label = clist,
     legend=:outertopright, 
     xlabel = "Days since 100th Case\nEnd of data: "*updated, xguidefontsize=8,
     title = "Corona 2020\nReproduction Number R - Selected Countries")




savefig("figs/cfm_05.png")

Rlast = [findfirst( x-> ismissing(x), R[:,i]) for i in 1:size(R)[2]]
for i in 1:length(Rlast)
    if Rlast[i] == nothing
       Rlast[i] = size(R,1)
    else
       Rlast[i]= Rlast[i] - 1
    end
end

labels1 = String[]
for i in 1:length(names(df_R0)) push!(labels1, String(names(df_R0)[i])) end
labels = reshape(labels1,1,:)

plot([20:size(R)[1]],R[20:end,:],
     label = clist,
     legend=:outertopright, 
     xlabel = "Days since 100th Case\nEnd of data: "*updated, xguidefontsize=8,
     annotations=([(Rlast[i], R[Rlast[i],i],text(labels[i][1:2], :left, 8)) for i in 1:length(Rlast)]),
     title = "Corona 2020\nReproduction Number R - Selected Countries")



savefig("figs/cfm_06.png")
