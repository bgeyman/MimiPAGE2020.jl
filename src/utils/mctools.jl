"""
Create a parameter `component`_`name` with the given value,
and connect parameter `name` within `component` to this distinct global parameter.
"""
function setdistinctparameter(m::Model, component::Symbol, name::Symbol, value)
    globalname = Symbol(lowercase(string(component, '_', name)))

    #TODO:  handle the different methods for setting this parameter
    set_external_parameter(m, globalname, value)

    #connect_parameter(m, component, name, globalname) # BUG: Cannot use this, because `checklabels` misuses globalname.  Instead, doing the below.
    p = m.external_params[globalname]
    Mimi.disconnect!(m, component, name)
    x = Mimi.ExternalParameterConnection(component, name, p)
    push!(m.external_parameter_connections, x)

    m.mi = Nullable{Mimi.ModelInstance}()
    nothing
end

"""
Change the value of an external parameter
"""
function update_external_param(m::Model, name::Symbol, value::Float64)
    m.external_params[Symbol(lowercase(string(name)))].value = value
end

function update_external_param(m::Model, name::Symbol, value::AbstractArray)
    m.external_params[Symbol(lowercase(string(name)))].values = value
end
