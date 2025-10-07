package handler

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/iqbaldwi09/bioskop/internal/domain"
	"github.com/iqbaldwi09/bioskop/internal/usecase"
)

type ShowtimeHandler struct {
	usecase *usecase.ShowtimeUsecase
}

func NewShowtimeHandler(u *usecase.ShowtimeUsecase) *ShowtimeHandler {
	return &ShowtimeHandler{usecase: u}
}

func (h *ShowtimeHandler) List(c *gin.Context) {
	showtimes, err := h.usecase.GetAll()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, showtimes)
}

func (h *ShowtimeHandler) GetByID(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	showtime, err := h.usecase.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Showtime not found"})
		return
	}

	c.JSON(http.StatusOK, showtime)
}

func (h *ShowtimeHandler) Create(c *gin.Context) {
	var s domain.Showtime
	if err := c.ShouldBindJSON(&s); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	err := h.usecase.Create(&s)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Showtime created successfully"})
}

func (h *ShowtimeHandler) Update(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	var s domain.Showtime
	if err := c.ShouldBindJSON(&s); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	s.ID = id

	err = h.usecase.Update(&s)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Showtime updated successfully"})
}

func (h *ShowtimeHandler) Delete(c *gin.Context) {
	idParam := c.Param("id")
	id, err := strconv.ParseInt(idParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID"})
		return
	}

	err = h.usecase.Delete(id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Showtime deleted successfully"})
}
