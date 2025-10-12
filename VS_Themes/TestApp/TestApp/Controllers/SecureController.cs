using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using TestApp.Entities;

namespace TestApp.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SecureController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;

        public SecureController(UserManager<ApplicationUser> userManager)
        {
            _userManager = userManager;
        }

        [Authorize]
        [HttpGet("protected")]
        public async Task<IActionResult> GetSecret()
        {
            ClaimsPrincipal currentUser = this.User;

            var userDetails = await _userManager.FindByNameAsync(currentUser.Identity.Name);

            return Ok($"Hello {userDetails.UserName}");
        }
    }
}
