using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using BSTU.Results.Collection;
using BSTU.Results.Authenticate;

namespace REST01.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ResultsController : ControllerBase
{
    private readonly IResultsService _resultsService;
    private readonly IAuthenticateService _authenticateService;

    public ResultsController(IResultsService resultsService, IAuthenticateService authenticateService)
    {
        _resultsService = resultsService;
        _authenticateService = authenticateService;
    }

    [HttpGet]
    [Authorize(Policy = "ReaderPolicy")]
    public ActionResult GetAll()
    {
        var items = _resultsService.GetAll();
        if (!items.Any()) return NoContent();
        return Ok(items);
    }

    [HttpGet("{k:int}")]
    [Authorize(Policy = "ReaderPolicy")]
    public ActionResult GetByKey(int k)
    {
        var item = _resultsService.GetByKey(k);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost]
    [Authorize(Policy = "WriterPolicy")]
    public ActionResult Post([FromBody] ValueModel model)
    {
        if (string.IsNullOrEmpty(model.Value)) return BadRequest();
        var item = _resultsService.Add(model.Value);
        return Created($"/api/Results/{item.Key}", item);
    }

    [HttpPut("{k:int}")]
    [Authorize(Policy = "WriterPolicy")]
    public ActionResult Put(int k, [FromBody] ValueModel model)
    {
        if (string.IsNullOrEmpty(model.Value)) return BadRequest();
        var item = _resultsService.Update(k, model.Value);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpDelete("{k:int}")]
    [Authorize(Policy = "WriterPolicy")]
    public ActionResult Delete(int k)
    {
        var item = _resultsService.Delete(k);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost("SignIn")]
    [AllowAnonymous]
    public ActionResult SignIn([FromBody] LoginModel model)
    {
        if (string.IsNullOrEmpty(model.Login) || string.IsNullOrEmpty(model.Password)) return BadRequest();
        var token = _authenticateService.SignIn(model);
        if (token == null) return NotFound("Invalid credentials");
        return Ok(new { Token = token });
    }
}

public class ValueModel
{
    public string Value { get; set; } = string.Empty;
}