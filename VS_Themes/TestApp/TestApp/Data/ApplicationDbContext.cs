using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using TestApp.Entities;

namespace TestApp.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>  
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) 
            : base(options)
        {
        }
    }
}
