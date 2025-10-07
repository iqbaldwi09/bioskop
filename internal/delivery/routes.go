package delivery

import (
	"github.com/iqbaldwi09/bioskop/internal/handler"
	"github.com/iqbaldwi09/bioskop/internal/middleware"
	"github.com/iqbaldwi09/bioskop/internal/repository"
	"github.com/iqbaldwi09/bioskop/internal/usecase"

	"github.com/gin-gonic/gin"
	"github.com/jmoiron/sqlx"
)

func InitRoutes(r *gin.Engine, db *sqlx.DB) {
	api := r.Group("/api/v1")

	userRepo := repository.NewUserRepository(db)
	userUsecase := usecase.NewUserUsecase(userRepo)
	userHandler := handler.NewUserHandler(userUsecase)

	showtimeRepo := repository.NewShowtimeRepository(db)
	showtimeUsecase := usecase.NewShowtimeUsecase(showtimeRepo)
	showtimeHandler := handler.NewShowtimeHandler(showtimeUsecase)

	api.POST("/login", userHandler.Login)

	showtimeRoutes := api.Group("/showtimes", middleware.AuthMiddleware())
	{
		showtimeRoutes.POST("", showtimeHandler.Create)
		showtimeRoutes.GET("", showtimeHandler.List)
		showtimeRoutes.GET("/:id", showtimeHandler.GetByID)
		showtimeRoutes.PUT("/:id", showtimeHandler.Update)
		showtimeRoutes.DELETE("/:id", showtimeHandler.Delete)
	}
}
