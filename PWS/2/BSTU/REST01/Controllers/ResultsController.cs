using BSTU.Results.Collection;
using BSTU.Results.Authenticate;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace REST01.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ResultsController : ControllerBase
    {
        private readonly IResultsCollection _resultsCollection;
        private readonly IAuthenticateService _authenticateService;

        public ResultsController(
            IResultsCollection resultsCollection, 
            IAuthenticateService authenticateService)
        {
            _resultsCollection = resultsCollection;
            _authenticateService = authenticateService;
        }

        [HttpPost("SignIn")]
        [AllowAnonymous]
        public IActionResult SignIn([FromBody] LoginModel model)
        {
            if (string.IsNullOrWhiteSpace(model?.Login) || string.IsNullOrWhiteSpace(model.Password))
                return BadRequest("Login and password are required");

            var token = _authenticateService.Authenticate(model.Login, model.Password);
            if (token == null)
                return NotFound("Invalid login or password");

            return Ok(new { Token = token });
        }

        [HttpGet]
        [Authorize(Policy = "Reader")]
        public async Task<IActionResult> GetAll()
        {
            try
            {
                var results = await _resultsCollection.GetAllAsync();
                if (results == null || !results.Any())
                    return NoContent();

                return Ok(results);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpGet("{k:int}")]
        [Authorize(Policy = "Reader")]
        public async Task<IActionResult> Get(int k)
        {
            try
            {
                var result = await _resultsCollection.GetAsync(k);
                if (result == null)
                    return NotFound($"Item with key {k} not found");

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPost]
        [Authorize(Policy = "Writer")]
        public async Task<IActionResult> Post([FromBody] ValueModel model)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(model?.Value))
                    return BadRequest("Value is required");

                var result = await _resultsCollection.AddAsync(model.Value);
                return CreatedAtAction(nameof(Get), new { k = result.Key }, result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpPut("{k:int}")]
        [Authorize(Policy = "Writer")]
        public async Task<IActionResult> Put(int k, [FromBody] ValueModel model)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(model?.Value))
                    return BadRequest("Value is required");

                var result = await _resultsCollection.UpdateAsync(k, model.Value);
                if (result == null)
                    return NotFound($"Item with key {k} not found");

                return Ok(result);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpDelete("{k:int}")]
        [Authorize(Policy = "Writer")]
        public async Task<IActionResult> Delete(int k)
        {
            try
            {
                var result = await _resultsCollection.DeleteAsync(k);
                if (result == null)
                    return NotFound($"Item with key {k} not found");

                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }
    }

    public class LoginModel
    {
        public string Login { get; set; }
        public string Password { get; set; }
    }

    public class ValueModel
    {
        public string Value { get; set; }
    }
}