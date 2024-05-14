using Healthtrackr.Api.Extensions;
using Healthtrackr.Api.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddSingleton<IWeightManager, FakeWeightManager>();

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();

app.RegisterWeightEndpoints();

app.Run();
